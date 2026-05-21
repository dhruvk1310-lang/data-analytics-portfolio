"""
CT Hospital Price Transparency Scraper
=======================================
Downloads CMS-mandated machine-readable price files from 5 Connecticut
hospitals and extracts prices for TARGET_CPTS CPT codes.

CMS 45 CFR 180 requires hospitals to publish:
  - Gross charge (chargemaster list price)
  - Discounted cash price
  - Payer-specific negotiated charges (by insurer)
  - De-identified min/max negotiated charges

Supports both CMS standard JSON format and CSV chargemasters.
Large files (100MB+) are streamed in chunks to avoid memory issues.

Usage:
    python scraper/scraper.py           # scrape all hospitals
    python scraper/scraper.py --demo    # use synthetic fallback data
"""

import argparse
import io
import json
import re
import sys
import time
import zipfile
from pathlib import Path

import pandas as pd
import requests
from bs4 import BeautifulSoup
from tqdm import tqdm

ROOT    = Path(__file__).parent.parent
RAW_DIR = ROOT / "data" / "raw"
RAW_DIR.mkdir(parents=True, exist_ok=True)

sys.path.insert(0, str(Path(__file__).parent))
from hospitals import HOSPITALS, TARGET_CPTS

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36"
    ),
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
}

CHUNK_SIZE = 1024 * 1024  # 1 MB chunks for large file streaming


# ── Download helpers ──────────────────────────────────────────────────────────

def stream_download(url: str, dest: Path, session: requests.Session) -> bool:
    """Stream-download a potentially large file. Returns True on success."""
    try:
        resp = session.get(url, stream=True, timeout=30, headers=HEADERS)
        resp.raise_for_status()
        total = int(resp.headers.get("content-length", 0))
        with open(dest, "wb") as f, tqdm(
            total=total, unit="B", unit_scale=True,
            desc=f"  {dest.name}", leave=False
        ) as bar:
            for chunk in resp.iter_content(CHUNK_SIZE):
                f.write(chunk)
                bar.update(len(chunk))
        return True
    except Exception as e:
        print(f"    ✗ {url}: {e}")
        return False


def find_file_url_on_page(landing_url: str, session: requests.Session) -> str | None:
    """Scrape landing page to find link to machine-readable price file."""
    try:
        resp = session.get(landing_url, timeout=15, headers=HEADERS)
        soup = BeautifulSoup(resp.text, "lxml")
        # Look for links containing typical price file keywords
        patterns = re.compile(
            r"(standard.charge|chargemaster|price.transparen|cdm|machine.readable)",
            re.I
        )
        for a in soup.find_all("a", href=True):
            href = a["href"]
            text = a.get_text(strip=True)
            if patterns.search(href) or patterns.search(text):
                if any(href.endswith(ext) for ext in [".json", ".csv", ".zip", ".xlsx"]):
                    if href.startswith("http"):
                        return href
                    return landing_url.split("/")[0] + "//" + landing_url.split("/")[2] + href
    except Exception as e:
        print(f"    ✗ Could not scrape landing page: {e}")
    return None


# ── Parsers ───────────────────────────────────────────────────────────────────

def normalize_code(code) -> str:
    """Strip leading zeros and whitespace from CPT codes."""
    return str(code).strip().lstrip("0") if code else ""


def parse_cms_json(path: Path, hospital_name: str) -> pd.DataFrame:
    """
    Parse CMS standard JSON format (schema v2.0).
    Extracts gross_charge, discounted_cash, min/max negotiated for TARGET_CPTS.
    """
    rows = []
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        data = json.load(f)

    items = data.get("standard_charge_information", [])
    for item in items:
        codes = item.get("code_information", [])
        cpt_codes = [
            normalize_code(c["code"])
            for c in codes
            if str(c.get("type", "")).upper() in ("CPT", "HCPCS")
        ]
        matched = [c for c in cpt_codes if c in TARGET_CPTS]
        if not matched:
            continue

        description = item.get("description", "")
        for charge in item.get("standard_charges", []):
            setting = charge.get("setting", "")
            rows.append({
                "hospital":         hospital_name,
                "cpt_code":         matched[0],
                "description":      description,
                "setting":          setting,
                "gross_charge":     charge.get("gross_charge"),
                "discounted_cash":  charge.get("discounted_cash"),
                "min_negotiated":   charge.get("minimum"),
                "max_negotiated":   charge.get("maximum"),
            })
    return pd.DataFrame(rows)


def parse_csv_chargemaster(path: Path, hospital_name: str) -> pd.DataFrame:
    """
    Parse CSV chargemaster. Column names vary widely — use heuristics.
    """
    rows = []
    # Try common encodings
    for enc in ["utf-8", "latin-1", "cp1252"]:
        try:
            df = pd.read_csv(path, encoding=enc, dtype=str, low_memory=False)
            break
        except Exception:
            continue
    else:
        print(f"    ✗ Could not read CSV: {path}")
        return pd.DataFrame()

    # Normalize column names
    df.columns = [c.strip().lower().replace(" ", "_") for c in df.columns]

    # Find CPT code column
    code_col = next(
        (c for c in df.columns if any(k in c for k in ["cpt", "hcpcs", "code", "proc"])),
        None
    )
    if not code_col:
        print(f"    ✗ No CPT code column found in {path.name}")
        return pd.DataFrame()

    # Find price columns (heuristic)
    def find_col(*keywords):
        for kw in keywords:
            for c in df.columns:
                if kw in c:
                    return c
        return None

    gross_col = find_col("gross", "chargemaster", "list_price", "charge")
    cash_col  = find_col("cash", "self_pay", "discounted")
    min_col   = find_col("min", "minimum")
    max_col   = find_col("max", "maximum")

    df["_cpt_norm"] = df[code_col].apply(normalize_code)
    matched = df[df["_cpt_norm"].isin(TARGET_CPTS)]

    for _, row in matched.iterrows():
        def safe_float(col):
            if col and col in row.index:
                try:
                    return float(str(row[col]).replace("$", "").replace(",", "").strip())
                except Exception:
                    return None
            return None

        rows.append({
            "hospital":        hospital_name,
            "cpt_code":        row["_cpt_norm"],
            "description":     row.get("description", row.get("item_description", "")),
            "setting":         row.get("setting", row.get("type", "")),
            "gross_charge":    safe_float(gross_col),
            "discounted_cash": safe_float(cash_col),
            "min_negotiated":  safe_float(min_col),
            "max_negotiated":  safe_float(max_col),
        })

    return pd.DataFrame(rows)


def parse_file(path: Path, fmt: str, hospital_name: str) -> pd.DataFrame:
    suffix = path.suffix.lower()
    if suffix == ".zip":
        with zipfile.ZipFile(path) as z:
            names = z.namelist()
            inner = next((n for n in names if n.endswith((".json", ".csv"))), None)
            if not inner:
                return pd.DataFrame()
            with z.open(inner) as f:
                content = f.read()
            tmp = RAW_DIR / inner.split("/")[-1]
            tmp.write_bytes(content)
            path = tmp
            suffix = tmp.suffix.lower()

    if suffix == ".json" or fmt == "json":
        return parse_cms_json(path, hospital_name)
    else:
        return parse_csv_chargemaster(path, hospital_name)


# ── Demo / synthetic fallback ─────────────────────────────────────────────────

def build_demo_data() -> pd.DataFrame:
    """
    Realistic synthetic prices based on publicly cited CT hospital price ranges.
    Used when scraping fails or --demo flag is passed.
    Source ranges: CMS hospital compare, CT OHS reports, news coverage.
    """
    import numpy as np
    rng = np.random.default_rng(99)

    # Base prices per CPT (median market estimate for CT)
    base_prices = {
        "70553": 1800, "70450": 900,  "74177": 1400, "71046": 250,
        "72148": 1600, "93306": 1200, "85025": 85,   "80048": 120,
        "83036": 65,   "82565": 55,   "36415": 35,   "99284": 1400,
        "99285": 2200, "99213": 180,  "45378": 1800, "77067": 350,
        "93000": 120,  "27447": 28000,"27130": 25000, "43239": 2200,
    }

    # Hospital multipliers (relative cost index — higher = more expensive)
    hospital_mult = {
        "Yale New Haven Hospital": 1.55,
        "Hartford Hospital":       1.35,
        "UConn Health":            1.10,
        "Stamford Hospital":       1.40,
        "Bridgeport Hospital":     0.95,
    }

    rows = []
    for hosp, mult in hospital_mult.items():
        for cpt, base in base_prices.items():
            gross = round(base * mult * rng.uniform(0.92, 1.12), 2)
            cash  = round(gross * rng.uniform(0.35, 0.55), 2)
            mn    = round(cash  * rng.uniform(0.75, 0.95), 2)
            mx    = round(gross * rng.uniform(0.60, 0.80), 2)
            rows.append({
                "hospital": hosp, "cpt_code": cpt,
                "description": TARGET_CPTS[cpt][2],
                "setting": "outpatient",
                "gross_charge": gross, "discounted_cash": cash,
                "min_negotiated": mn,  "max_negotiated": mx,
            })

    return pd.DataFrame(rows)


# ── Main ──────────────────────────────────────────────────────────────────────

def scrape_hospital(hospital: dict, session: requests.Session) -> pd.DataFrame:
    name  = hospital["name"]
    short = hospital["short"]
    cache = RAW_DIR / f"{short}_prices.csv"

    if cache.exists():
        print(f"  [cache] {name}")
        return pd.read_csv(cache)

    print(f"\n  Scraping {name}...")
    urls = [hospital["direct_url"]] + hospital.get("alt_urls", [])

    # Try direct URLs first
    raw_path = None
    for url in urls:
        ext = "." + url.split(".")[-1].split("?")[0]
        dest = RAW_DIR / f"{short}_raw{ext}"
        print(f"  Trying: {url}")
        if stream_download(url, dest, session):
            raw_path = dest
            break

    # Fall back to scraping the landing page
    if not raw_path:
        print(f"  Trying landing page: {hospital['landing_page']}")
        found_url = find_file_url_on_page(hospital["landing_page"], session)
        if found_url:
            ext = "." + found_url.split(".")[-1].split("?")[0]
            dest = RAW_DIR / f"{short}_raw{ext}"
            if stream_download(found_url, dest, session):
                raw_path = dest

    if not raw_path:
        print(f"  ✗ Could not download price file for {name}")
        return pd.DataFrame()

    print(f"  Parsing {raw_path.name}...")
    df = parse_file(raw_path, hospital["file_format"], name)
    if df.empty:
        print(f"  ✗ No matching CPT codes found in {name} file")
        return df

    df.to_csv(cache, index=False)
    print(f"  ✓ {len(df)} rows → {cache.name}")
    return df


def main(demo: bool = False):
    print("\n── CT Hospital Price Transparency Scraper ──\n")

    if demo:
        print("Running on synthetic demo data (--demo flag).\n")
        df = build_demo_data()
    else:
        session = requests.Session()
        session.headers.update(HEADERS)
        frames = []
        for hospital in HOSPITALS:
            df = scrape_hospital(hospital, session)
            if not df.empty:
                frames.append(df)
            time.sleep(2)

        if not frames:
            print("\n⚠  No data scraped. Using demo data instead.\n")
            df = build_demo_data()
        else:
            df = pd.concat(frames, ignore_index=True)

    out = RAW_DIR / "all_prices.csv"
    df.to_csv(out, index=False)
    print(f"\n✓ Saved {len(df)} rows → {out}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--demo", action="store_true")
    args = parser.parse_args()
    main(demo=args.demo)
