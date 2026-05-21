"""
CT Hospital Price Analysis
===========================
Reads scraped/demo price data and computes:
  1. Per-CPT price comparison across all 5 hospitals
  2. Price ratio (most expensive / cheapest) per procedure
  3. Dollar gap (max - min gross charge)
  4. Rankings: most/least expensive hospital overall
  5. Category-level aggregates (Imaging, Lab, ED, Procedures)

Outputs:
  data/processed/price_comparison.csv   ← wide format, one row per CPT
  data/processed/all_prices_clean.csv   ← long format, cleaned
  data/processed/summary_stats.json     ← for dashboard

Usage:
    python analysis/analyze.py
    python analysis/analyze.py --demo
"""

import argparse
import json
import sys
from pathlib import Path

import numpy as np
import pandas as pd

ROOT     = Path(__file__).parent.parent
RAW_CSV  = ROOT / "data" / "raw" / "all_prices.csv"
PROC_DIR = ROOT / "data" / "processed"
PROC_DIR.mkdir(parents=True, exist_ok=True)

sys.path.insert(0, str(ROOT / "scraper"))
from hospitals import HOSPITALS, TARGET_CPTS

HOSPITAL_NAMES  = [h["name"]  for h in HOSPITALS]
HOSPITAL_SHORTS = {h["name"]: h["short"] for h in HOSPITALS}


# ── Clean & deduplicate ───────────────────────────────────────────────────────

def clean(df: pd.DataFrame) -> pd.DataFrame:
    for col in ["gross_charge", "discounted_cash", "min_negotiated", "max_negotiated"]:
        df[col] = pd.to_numeric(df[col], errors="coerce")

    # Remove obvious data errors (e.g. $0 or $1M+ for routine labs)
    df = df[df["gross_charge"] > 1]
    df = df[df["gross_charge"] < 500_000]

    # Keep outpatient rows preferentially; if none, keep all
    out = df[df["setting"].str.lower().str.contains("out", na=True)]
    df  = out if not out.empty else df

    # One row per hospital × CPT: take median gross charge
    df = (
        df.groupby(["hospital", "cpt_code"], as_index=False)
        .agg(
            description      =("description",     "first"),
            gross_charge     =("gross_charge",     "median"),
            discounted_cash  =("discounted_cash",  "median"),
            min_negotiated   =("min_negotiated",   "median"),
            max_negotiated   =("max_negotiated",   "median"),
        )
    )
    return df


# ── Wide comparison table ─────────────────────────────────────────────────────

def build_comparison(df: pd.DataFrame) -> pd.DataFrame:
    """
    Wide table: one row per CPT code, one column per hospital (gross charge).
    Adds: label, category, price_ratio, dollar_gap, cheapest, most_expensive.
    """
    pivot = df.pivot_table(
        index="cpt_code", columns="hospital",
        values="gross_charge", aggfunc="median"
    ).reset_index()

    # Add labels from config
    pivot["label"]    = pivot["cpt_code"].map(lambda c: TARGET_CPTS.get(c, (c,))[0])
    pivot["category"] = pivot["cpt_code"].map(lambda c: TARGET_CPTS.get(c, ("",""))[1])
    pivot["full_desc"]= pivot["cpt_code"].map(lambda c: TARGET_CPTS.get(c, ("","",""))[2])

    hosp_cols = [c for c in pivot.columns if c in HOSPITAL_NAMES]

    pivot["max_price"]       = pivot[hosp_cols].max(axis=1)
    pivot["min_price"]       = pivot[hosp_cols].min(axis=1)
    pivot["avg_price"]       = pivot[hosp_cols].mean(axis=1).round(2)
    pivot["dollar_gap"]      = (pivot["max_price"] - pivot["min_price"]).round(2)
    pivot["price_ratio"]     = (pivot["max_price"] / pivot["min_price"]).round(2)
    pivot["most_expensive"]  = pivot[hosp_cols].idxmax(axis=1).apply(
        lambda n: HOSPITAL_SHORTS.get(n, n))
    pivot["cheapest"]        = pivot[hosp_cols].idxmin(axis=1).apply(
        lambda n: HOSPITAL_SHORTS.get(n, n))

    return pivot.sort_values("dollar_gap", ascending=False).reset_index(drop=True)


# ── Hospital rankings ─────────────────────────────────────────────────────────

def hospital_rankings(df: pd.DataFrame) -> pd.DataFrame:
    """Rank hospitals by average gross charge across all matched CPTs."""
    return (
        df.groupby("hospital")["gross_charge"]
        .agg(avg_gross=("median"), procedures_found="count")
        .rename(columns={"avg_gross": "avg_gross_charge"})
        .reset_index()
        .sort_values("avg_gross_charge", ascending=False)
        .reset_index(drop=True)
    )


# ── Category summary ──────────────────────────────────────────────────────────

def category_summary(comparison: pd.DataFrame) -> pd.DataFrame:
    hosp_cols = [c for c in comparison.columns if c in HOSPITAL_NAMES]
    rows = []
    for cat, grp in comparison.groupby("category"):
        row = {"category": cat, "procedures": len(grp),
               "avg_price_ratio": grp["price_ratio"].mean().round(2),
               "max_dollar_gap":  grp["dollar_gap"].max()}
        for h in hosp_cols:
            row[HOSPITAL_SHORTS[h]+"_avg"] = grp[h].mean().round(2)
        rows.append(row)
    return pd.DataFrame(rows).sort_values("avg_price_ratio", ascending=False)


# ── Key stats ─────────────────────────────────────────────────────────────────

def key_stats(comparison: pd.DataFrame, rankings: pd.DataFrame) -> dict:
    top_gap = comparison.iloc[0]
    top_ratio = comparison.loc[comparison["price_ratio"].idxmax()]
    return {
        "largest_dollar_gap": {
            "procedure":  top_gap["label"],
            "cpt":        top_gap["cpt_code"],
            "gap":        round(float(top_gap["dollar_gap"]), 2),
            "min":        round(float(top_gap["min_price"]), 2),
            "max":        round(float(top_gap["max_price"]), 2),
            "cheapest":   top_gap["cheapest"],
            "priciest":   top_gap["most_expensive"],
        },
        "highest_price_ratio": {
            "procedure":  top_ratio["label"],
            "cpt":        top_ratio["cpt_code"],
            "ratio":      round(float(top_ratio["price_ratio"]), 2),
            "min":        round(float(top_ratio["min_price"]), 2),
            "max":        round(float(top_ratio["max_price"]), 2),
        },
        "most_expensive_hospital": rankings.iloc[0]["hospital"],
        "cheapest_hospital":       rankings.iloc[-1]["hospital"],
        "avg_price_ratio_all":     round(float(comparison["price_ratio"].mean()), 2),
        "max_price_ratio":         round(float(comparison["price_ratio"].max()), 2),
        "total_procedures_compared": int(len(comparison)),
    }


# ── Main ──────────────────────────────────────────────────────────────────────

def main(demo: bool = False):
    print("── CT Hospital Price Analysis ──\n")

    if demo or not RAW_CSV.exists():
        if not demo:
            print("⚠  No scraped data. Run scraper first or use --demo.\n")
        sys.path.insert(0, str(ROOT / "scraper"))
        from scraper import build_demo_data
        raw = build_demo_data()
    else:
        raw = pd.read_csv(RAW_CSV)
        print(f"Loaded {len(raw)} rows from {RAW_CSV}\n")

    df = clean(raw)
    print(f"After cleaning: {len(df)} rows across "
          f"{df['hospital'].nunique()} hospitals, "
          f"{df['cpt_code'].nunique()} CPT codes\n")

    comparison = build_comparison(df)
    rankings   = hospital_rankings(df)
    cat_sum    = category_summary(comparison)
    stats      = key_stats(comparison, rankings)

    # ── Print summary
    print("── Top 5 procedures by dollar gap ──")
    hosp_cols = [c for c in comparison.columns if c in HOSPITAL_NAMES]
    print(comparison[["label","min_price","max_price","dollar_gap","price_ratio"]]
          .head(5).to_string(index=False))

    print("\n── Hospital rankings (avg gross charge) ──")
    print(rankings.to_string(index=False))

    print(f"\n── Key stat ──")
    lr = stats["largest_dollar_gap"]
    print(f"  {lr['procedure']}: ${lr['min']:,.0f} (cheapest) "
          f"→ ${lr['max']:,.0f} (priciest) — ${lr['gap']:,.0f} gap")

    # ── Save outputs
    out_compare = PROC_DIR / "price_comparison.csv"
    out_clean   = PROC_DIR / "all_prices_clean.csv"
    out_json    = PROC_DIR / "summary_stats.json"

    comparison.to_csv(out_compare, index=False)
    df.to_csv(out_clean, index=False)

    payload = {
        "is_demo":      demo or not RAW_CSV.exists(),
        "stats":        stats,
        "comparison":   comparison.fillna("").to_dict(orient="records"),
        "rankings":     rankings.fillna("").to_dict(orient="records"),
        "categories":   cat_sum.fillna("").to_dict(orient="records"),
        "hospital_names": HOSPITAL_NAMES,
        "hospital_shorts": HOSPITAL_SHORTS,
        "cpt_labels":   {k: v[0] for k, v in TARGET_CPTS.items()},
    }
    with open(out_json, "w") as f:
        json.dump(payload, f, indent=2, default=str)

    print(f"\n✓ price_comparison.csv → {out_compare}")
    print(f"✓ all_prices_clean.csv → {out_clean}")
    print(f"✓ summary_stats.json   → {out_json}")
    print("\nNow run: python dashboard/create_excel.py")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--demo", action="store_true")
    args = parser.parse_args()
    main(demo=args.demo)
