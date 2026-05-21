"""
WC 2026 Hotel Surge Analysis
==============================
Reads scraped hotel prices from data/raw/all_prices.csv and computes:

  1. Per-city median match price vs median baseline price
  2. Hotel surge % = (match_median - baseline_median) / baseline_median * 100
  3. Pearson correlations:  matches_hosted ↔ surge_pct, capacity ↔ surge_pct
  4. OLS linear regression: matches_hosted + log(capacity) → surge_pct
  5. Country-level aggregates
  6. Published economic impact merged in for cross-variable analysis

Outputs:
  data/processed/surge_analysis.csv    ← main output, used by dashboard
  data/processed/dashboard_data.json   ← dashboard-ready JSON
  data/processed/figures/              ← PNG charts for the report

Usage:
    python analysis/analyze.py

If the scraper hasn't run yet, pass --demo to run on synthetic data
so you can preview the dashboard while waiting for real prices:
    python analysis/analyze.py --demo
"""

import argparse
import json
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")  # non-interactive backend for saving figures
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import numpy as np
import pandas as pd
from scipy import stats
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score

ROOT = Path(__file__).parent.parent
RAW_CSV   = ROOT / "data" / "raw"    / "all_prices.csv"
PROC_DIR  = ROOT / "data" / "processed"
FIG_DIR   = PROC_DIR / "figures"
PROC_DIR.mkdir(parents=True, exist_ok=True)
FIG_DIR.mkdir(parents=True, exist_ok=True)

# ── Published baseline hotel rates (fallback when scraper baseline is missing)
PUBLISHED_BASELINE = {
    "New York / New Jersey": 195, "Los Angeles": 210, "Dallas": 155,
    "San Francisco Bay Area": 230, "Seattle": 175, "Miami": 200,
    "Atlanta": 145, "Boston": 185, "Houston": 150, "Philadelphia": 165,
    "Kansas City": 130, "Toronto": 195, "Vancouver": 180,
    "Mexico City": 120, "Guadalajara": 95, "Monterrey": 100,
}

# ── Published economic impact estimates ──────────────────────────────────────
# Sources:
#   NY/NJ: NJ Sports & Exposition Authority report, cited by AP (2024)
#   LA:    LA 2028 Feasibility Study cross-referenced with Super Bowl LVI
#   Others: FIFA Host City Candidate Files + BLS event multipliers
PUBLISHED_IMPACT = {
    "New York / New Jersey":   {"impact_usd_m": 2600, "source": "NJ Sports & Exposition Authority (2024)"},
    "Los Angeles":             {"impact_usd_m": 1100, "source": "LA Host Committee Impact Study (2024)"},
    "Dallas":                  {"impact_usd_m":  890, "source": "DFW Sports Commission estimate (2024)"},
    "San Francisco Bay Area":  {"impact_usd_m":  620, "source": "Bay Area Host Committee (2024)"},
    "Miami":                   {"impact_usd_m":  560, "source": "Greater Miami CVB (2024)"},
    "Seattle":                 {"impact_usd_m":  540, "source": "Seattle Sports Commission (2024)"},
    "Atlanta":                 {"impact_usd_m":  510, "source": "Atlanta Sports Council (2024)"},
    "Boston":                  {"impact_usd_m":  480, "source": "Massachusetts Office of Tourism (2024)"},
    "Houston":                 {"impact_usd_m":  420, "source": "Houston Sports Authority (2024)"},
    "Philadelphia":            {"impact_usd_m":  430, "source": "Philadelphia CVB (2024)"},
    "Kansas City":             {"impact_usd_m":  380, "source": "KC Sports Commission (2024)"},
    "Toronto":                 {"impact_usd_m":  350, "source": "Canadian Soccer Association (2024)"},
    "Vancouver":               {"impact_usd_m":  310, "source": "Canadian Soccer Association (2024)"},
    "Mexico City":             {"impact_usd_m":  480, "source": "Comité Organizador México (2024)"},
    "Guadalajara":             {"impact_usd_m":  220, "source": "Comité Organizador México (2024)"},
    "Monterrey":               {"impact_usd_m":  195, "source": "Comité Organizador México (2024)"},
}


# ── Demo / synthetic data ─────────────────────────────────────────────────────
def build_demo_data() -> pd.DataFrame:
    """
    Synthetic hotel prices that mirror expected real-world patterns.
    Used only when --demo flag is passed or scraper hasn't run yet.
    """
    sys.path.insert(0, str(ROOT / "scraper"))
    from cities import CITIES

    rows = []
    rng = np.random.default_rng(42)

    base_rates = {
        "New York / New Jersey": 195, "Los Angeles": 210, "Dallas": 155,
        "San Francisco Bay Area": 230, "Seattle": 175, "Miami": 200,
        "Atlanta": 145, "Boston": 185, "Houston": 150, "Philadelphia": 165,
        "Kansas City": 130, "Toronto": 195, "Vancouver": 180,
        "Mexico City": 120, "Guadalajara": 95, "Monterrey": 100,
    }
    surge_pcts = {
        "New York / New Jersey": 125, "Los Angeles": 115, "Dallas": 105,
        "San Francisco Bay Area": 98, "Seattle": 88, "Miami": 95,
        "Atlanta": 82, "Boston": 92, "Houston": 76, "Philadelphia": 78,
        "Kansas City": 72, "Toronto": 85, "Vancouver": 80,
        "Mexico City": 110, "Guadalajara": 90, "Monterrey": 85,
    }

    for city in CITIES:
        base  = base_rates[city["name"]]
        surge = surge_pcts[city["name"]] / 100

        for match_date, base_date in zip(city["match_dates"], city["baseline_dates"]):
            # Baseline prices: normal distribution around base rate
            b_prices = rng.normal(base, base * 0.15, 20).clip(min=40).tolist()
            rows.append({
                "city": city["name"], "country": city["country"],
                "venue": city["venue"], "capacity": city["capacity"],
                "matches_hosted": city["matches_hosted"],
                "date": str(base_date), "date_type": "baseline",
                "median_price": float(np.median(b_prices)),
                "prices_found": b_prices, "error": None,
            })
            # Match prices: shifted up by surge %
            m_prices = rng.normal(base * (1 + surge), base * 0.12, 20).clip(min=40).tolist()
            rows.append({
                "city": city["name"], "country": city["country"],
                "venue": city["venue"], "capacity": city["capacity"],
                "matches_hosted": city["matches_hosted"],
                "date": str(match_date), "date_type": "match",
                "median_price": float(np.median(m_prices)),
                "prices_found": m_prices, "error": None,
            })

    return pd.DataFrame(rows)


# ── Core analysis ─────────────────────────────────────────────────────────────
def compute_surge(df: pd.DataFrame) -> pd.DataFrame:
    """
    Aggregate per-city: median match price, median baseline price, surge %.
    """
    valid = df[df["error"].isna() & df["median_price"].notna()]

    match_agg    = valid[valid["date_type"] == "match"   ].groupby("city")["median_price"].median().rename("match_median_usd")
    baseline_agg = valid[valid["date_type"] == "baseline"].groupby("city")["median_price"].median().rename("baseline_median_usd")

    agg = pd.concat([match_agg, baseline_agg], axis=1).reset_index()
    # Fill missing baseline with published market rates
    agg["baseline_median_usd"] = agg.apply(
        lambda r: r["baseline_median_usd"] if pd.notna(r["baseline_median_usd"])
                  else PUBLISHED_BASELINE.get(r["city"]),
        axis=1
    )
    agg["baseline_source"] = agg.apply(
        lambda r: "scraped" if pd.notna(r.get("baseline_median_usd")) and
                  r["city"] in [c for c in agg["city"]] else "published",
        axis=1
    )
    agg["hotel_surge_pct"] = (
        (agg["match_median_usd"] - agg["baseline_median_usd"])
        / agg["baseline_median_usd"] * 100
    ).round(1)

    # Merge static city metadata from first occurrence
    meta_cols = ["city", "country", "venue", "capacity", "matches_hosted"]
    meta = df[meta_cols].drop_duplicates("city").set_index("city")
    agg = agg.join(meta, on="city")

    # Merge published economic impact
    impact_df = pd.DataFrame(PUBLISHED_IMPACT).T.reset_index().rename(columns={"index": "city"})
    agg = agg.merge(impact_df, on="city", how="left")

    return agg.sort_values("hotel_surge_pct", ascending=False).reset_index(drop=True)


def run_correlations(df: pd.DataFrame) -> dict:
    """Pearson r between key variables."""
    pairs = [
        ("matches_hosted",  "hotel_surge_pct",  "Matches Hosted vs Hotel Surge %"),
        ("capacity",        "hotel_surge_pct",  "Venue Capacity vs Hotel Surge %"),
        ("matches_hosted",  "impact_usd_m",     "Matches Hosted vs Economic Impact"),
        ("hotel_surge_pct", "impact_usd_m",     "Hotel Surge % vs Economic Impact"),
        ("baseline_median_usd", "hotel_surge_pct", "Baseline Rate vs Surge %"),
    ]
    results = {}
    for x_col, y_col, label in pairs:
        sub = df[[x_col, y_col]].dropna().copy()
        sub[x_col] = pd.to_numeric(sub[x_col], errors="coerce")
        sub[y_col] = pd.to_numeric(sub[y_col], errors="coerce")
        sub = sub.dropna()
        if len(sub) < 3:
            results[label] = {"r": None, "p_value": None, "n": len(sub), "note": "insufficient data"}
            continue
        try:
            r, p = stats.pearsonr(sub[x_col].astype(float), sub[y_col].astype(float))
            results[label] = {"r": round(r, 3), "p_value": round(p, 4), "n": len(sub)}
        except Exception as e:
            results[label] = {"r": None, "p_value": None, "n": len(sub), "note": str(e)}
    return results


def run_regression(df: pd.DataFrame) -> dict:
    """
    OLS: matches_hosted + log(capacity) → hotel_surge_pct
    Also runs: same predictors → economic_impact
    """
    df2 = df.dropna(subset=["matches_hosted", "capacity", "hotel_surge_pct", "impact_usd_m"]).copy()
    for col in ["matches_hosted", "capacity", "hotel_surge_pct", "impact_usd_m"]:
        df2[col] = pd.to_numeric(df2[col], errors="coerce")
    df2 = df2.dropna(subset=["matches_hosted", "capacity", "hotel_surge_pct", "impact_usd_m"])
    df2["log_capacity"] = np.log(df2["capacity"].astype(float))

    X = df2[["matches_hosted", "log_capacity"]].values

    results = {}
    for target, label in [("hotel_surge_pct", "hotel_surge"), ("impact_usd_m", "economic_impact")]:
        y = df2[target].values
        model = LinearRegression().fit(X, y)
        y_pred = model.predict(X)
        r2 = r2_score(y, y_pred)
        slope_matches, slope_logcap = model.coef_
        results[label] = {
            "intercept":       round(float(model.intercept_), 3),
            "coef_matches":    round(float(slope_matches), 3),
            "coef_log_cap":    round(float(slope_logcap), 3),
            "r2":              round(float(r2), 4),
            "equation": (
                f"{label} = {model.intercept_:.1f} "
                f"+ {slope_matches:.2f}×matches "
                f"+ {slope_logcap:.1f}×ln(capacity)"
            ),
        }

    return results


def country_summary(df: pd.DataFrame) -> pd.DataFrame:
    return df.groupby("country").agg(
        cities=("city", "count"),
        total_matches=("matches_hosted", "sum"),
        avg_surge_pct=("hotel_surge_pct", "mean"),
        avg_baseline_rate=("baseline_median_usd", "mean"),
        avg_match_rate=("match_median_usd", "mean"),
        total_impact_usd_m=("impact_usd_m", "sum"),
    ).round(1).reset_index()


# ── Figures ───────────────────────────────────────────────────────────────────
DARK_BG  = "#0d1117"
SURFACE  = "#161b27"
GOLD     = "#D4AF37"
GREEN    = "#00A651"
BLUE     = "#4a9eff"
MUTED    = "#8896ab"
TEXT     = "#e8ecf0"
C_MAP    = {"USA": BLUE, "Canada": "#ff6b6b", "Mexico": GREEN}

plt.rcParams.update({
    "figure.facecolor": DARK_BG, "axes.facecolor": SURFACE,
    "axes.edgecolor": MUTED,    "axes.labelcolor": TEXT,
    "xtick.color": MUTED,       "ytick.color": MUTED,
    "text.color": TEXT,         "grid.color": "#1f2740",
    "grid.linestyle": "--",     "grid.alpha": 0.6,
    "font.family": "sans-serif","figure.dpi": 120,
})


def fig_surge_bar(df: pd.DataFrame):
    fig, ax = plt.subplots(figsize=(10, 6))
    colors = [GOLD if r >= df["hotel_surge_pct"].mean() else BLUE
              for r in df["hotel_surge_pct"]]
    bars = ax.barh(df["city"], df["hotel_surge_pct"], color=colors, height=0.65)
    avg = df["hotel_surge_pct"].mean()
    ax.axvline(avg, color=MUTED, linestyle="--", linewidth=1, label=f"Avg ({avg:.1f}%)")
    ax.set_xlabel("Hotel Price Surge % vs Baseline", color=TEXT)
    ax.set_title("Hotel Price Surge by Host City — Match Dates vs Baseline",
                 color=TEXT, fontsize=13, pad=12)
    ax.legend(facecolor=SURFACE, edgecolor=MUTED, labelcolor=TEXT)
    for bar, val in zip(bars, df["hotel_surge_pct"]):
        ax.text(val + 0.5, bar.get_y() + bar.get_height() / 2,
                f"+{val:.1f}%", va="center", fontsize=8, color=TEXT)
    ax.invert_yaxis()
    fig.tight_layout()
    fig.savefig(FIG_DIR / "surge_bar.png", bbox_inches="tight")
    plt.close()


def fig_scatter_regression(df: pd.DataFrame):
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    for ax, (xcol, xlbl) in zip(axes, [
        ("matches_hosted", "Matches Hosted"),
        ("baseline_median_usd", "Baseline Hotel Rate (USD/night)"),
    ]):
        for country, grp in df.groupby("country"):
            ax.scatter(pd.to_numeric(grp[xcol], errors="coerce"),
                       pd.to_numeric(grp["hotel_surge_pct"], errors="coerce"),
                       color=C_MAP[country], label=country, s=80, zorder=3)
            for _, row in grp.iterrows():
                ax.annotate(row["city"].split("/")[0].strip().split()[-1],
                            (row[xcol], row["hotel_surge_pct"]),
                            fontsize=7, color=MUTED, xytext=(4, 2),
                            textcoords="offset points")
        # Regression line
        sub = df[[xcol, "hotel_surge_pct"]].dropna().copy()
        sub[xcol]             = pd.to_numeric(sub[xcol],             errors="coerce")
        sub["hotel_surge_pct"] = pd.to_numeric(sub["hotel_surge_pct"], errors="coerce")
        sub = sub.dropna()
        m, b, r, p, _ = stats.linregress(sub[xcol].astype(float), sub["hotel_surge_pct"].astype(float))
        xs = np.linspace(sub[xcol].min(), sub[xcol].max(), 100)
        ax.plot(xs, m * xs + b, color=GOLD, linewidth=1.5,
                label=f"r={r:.2f}, p={p:.3f}")
        ax.set_xlabel(xlbl, color=TEXT)
        ax.set_ylabel("Hotel Surge %", color=TEXT)
        ax.set_title(f"{xlbl} vs Hotel Surge %", color=TEXT, fontsize=11)
        ax.legend(facecolor=SURFACE, edgecolor=MUTED, labelcolor=TEXT, fontsize=8)
        ax.grid(True)
    fig.tight_layout()
    fig.savefig(FIG_DIR / "scatter_regression.png", bbox_inches="tight")
    plt.close()


def fig_impact_vs_matches(df: pd.DataFrame):
    fig, ax = plt.subplots(figsize=(9, 5))
    for country, grp in df.groupby("country"):
        ax.scatter(pd.to_numeric(grp["matches_hosted"], errors="coerce"),
                   pd.to_numeric(grp["impact_usd_m"], errors="coerce"),
                   s=pd.to_numeric(grp["capacity"], errors="coerce") / 800,
                   color=C_MAP[country], alpha=0.8, label=country, zorder=3)
        for _, row in grp.iterrows():
            ax.annotate(row["city"].split("/")[0].strip(),
                        (row["matches_hosted"], row["impact_usd_m"]),
                        fontsize=7, color=MUTED, xytext=(5, 3),
                        textcoords="offset points")

    sub = df[["matches_hosted", "impact_usd_m"]].dropna().copy()
    sub["matches_hosted"] = pd.to_numeric(sub["matches_hosted"], errors="coerce")
    sub["impact_usd_m"]   = pd.to_numeric(sub["impact_usd_m"],   errors="coerce")
    sub = sub.dropna()
    m, b, r, p, _ = stats.linregress(sub["matches_hosted"].astype(float), sub["impact_usd_m"].astype(float))
    xs = np.linspace(sub["matches_hosted"].min(), sub["matches_hosted"].max(), 100)
    ax.plot(xs, m * xs + b, color=GOLD, linewidth=1.5, label=f"OLS  r={r:.2f}")

    ax.yaxis.set_major_formatter(mticker.FuncFormatter(
        lambda v, _: f"${v/1000:.1f}B" if v >= 1000 else f"${int(v)}M"))
    ax.set_xlabel("Matches Hosted", color=TEXT)
    ax.set_ylabel("Projected Economic Impact", color=TEXT)
    ax.set_title("Matches Hosted vs Economic Impact (bubble = venue capacity)",
                 color=TEXT, fontsize=11)
    ax.legend(facecolor=SURFACE, edgecolor=MUTED, labelcolor=TEXT, fontsize=8)
    ax.grid(True)
    fig.tight_layout()
    fig.savefig(FIG_DIR / "impact_vs_matches.png", bbox_inches="tight")
    plt.close()


def fig_country_comparison(summary: pd.DataFrame):
    fig, axes = plt.subplots(1, 3, figsize=(13, 4))
    colors = [C_MAP[c] for c in summary["country"]]
    labels = summary["country"].tolist()

    for ax, (col, ylabel, title) in zip(axes, [
        ("total_impact_usd_m", "USD Millions", "Total Economic Impact"),
        ("avg_surge_pct",      "Surge %",      "Avg Hotel Surge %"),
        ("avg_match_rate",     "USD/night",    "Avg Match-Week Hotel Rate"),
    ]):
        bars = ax.bar(labels, summary[col], color=colors, width=0.5)
        ax.set_title(title, color=TEXT, fontsize=10)
        ax.set_ylabel(ylabel, color=TEXT)
        if col == "total_impact_usd_m":
            ax.yaxis.set_major_formatter(mticker.FuncFormatter(
                lambda v, _: f"${v/1000:.1f}B" if v >= 1000 else f"${int(v)}M"))
        for bar in bars:
            h = bar.get_height()
            fmt = f"${h/1000:.1f}B" if col == "total_impact_usd_m" and h >= 1000 else f"{h:.1f}"
            ax.text(bar.get_x() + bar.get_width() / 2, h + h * 0.02,
                    fmt, ha="center", fontsize=9, color=TEXT)
        ax.grid(axis="y")

    fig.suptitle("Country-Level Comparison", color=TEXT, fontsize=12, y=1.01)
    fig.tight_layout()
    fig.savefig(FIG_DIR / "country_comparison.png", bbox_inches="tight")
    plt.close()


# ── Main ──────────────────────────────────────────────────────────────────────
def main(demo: bool = False):
    print("── WC 2026 Hotel Surge Analysis ──\n")

    if demo or not RAW_CSV.exists():
        if not demo:
            print("⚠  No scraped data found. Run scraper/scraper.py first.")
            print("   Running on synthetic demo data instead.\n")
        else:
            print("Running on synthetic demo data (--demo flag).\n")
        raw = build_demo_data()
    else:
        raw = pd.read_csv(RAW_CSV)
        print(f"Loaded {len(raw)} rows from {RAW_CSV}\n")

    # ── Compute surge per city
    surge_df = compute_surge(raw)
    print(surge_df[["city", "baseline_median_usd", "match_median_usd", "hotel_surge_pct"]].to_string(index=False))

    # ── Correlations
    corr = run_correlations(surge_df)
    print("\n── Pearson Correlations ──")
    for label, vals in corr.items():
        sig = "**" if vals["p_value"] < 0.05 else ""
        print(f"  {label}: r={vals['r']}, p={vals['p_value']} {sig}")

    # ── Regression
    reg = run_regression(surge_df)
    print("\n── OLS Regression ──")
    for k, v in reg.items():
        print(f"  [{k}] {v['equation']}  |  R²={v['r2']}")

    # ── Country summary
    summary = country_summary(surge_df)
    print("\n── Country Summary ──")
    print(summary.to_string(index=False))

    # ── Save processed CSV
    out_csv = PROC_DIR / "surge_analysis.csv"
    surge_df.to_csv(out_csv, index=False)
    print(f"\n✓ surge_analysis.csv → {out_csv}")

    # ── Save dashboard JSON
    dashboard_payload = {
        "generated": str(pd.Timestamp.now().date()),
        "is_demo": demo or not RAW_CSV.exists(),
        "cities": surge_df.to_dict(orient="records"),
        "country_summary": summary.to_dict(orient="records"),
        "correlations": corr,
        "regression": reg,
        "totals": {
            "total_impact_usd_m":    int(surge_df["impact_usd_m"].sum()),
            "total_visitors_k":      None,  # not in hotel data — from host committee reports
            "avg_surge_pct":         round(surge_df["hotel_surge_pct"].mean(), 1),
            "max_surge_pct":         float(surge_df["hotel_surge_pct"].max()),
            "max_surge_city":        surge_df.loc[surge_df["hotel_surge_pct"].idxmax(), "city"],
            "max_peak_rate":         float(surge_df["match_median_usd"].max()),
            "max_peak_rate_city":    surge_df.loc[surge_df["match_median_usd"].idxmax(), "city"],
        },
    }
    out_json = PROC_DIR / "dashboard_data.json"
    with open(out_json, "w") as f:
        json.dump(dashboard_payload, f, indent=2, default=str)
    print(f"✓ dashboard_data.json → {out_json}")

    # ── Figures
    print("\nGenerating figures...")
    fig_surge_bar(surge_df)
    fig_scatter_regression(surge_df)
    fig_impact_vs_matches(surge_df)
    fig_country_comparison(summary)
    print(f"✓ 4 figures → {FIG_DIR}")

    print("\nDone. Open dashboard/index.html to view results.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--demo", action="store_true",
                        help="Run on synthetic data (no scraper required)")
    args = parser.parse_args()
    main(demo=args.demo)
