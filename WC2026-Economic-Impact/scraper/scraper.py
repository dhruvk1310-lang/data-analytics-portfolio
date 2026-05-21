"""
WC 2026 Hotel Price Scraper — Booking.com
==========================================
Uses Playwright (headless Chromium) to scrape median hotel nightly rates for:
  - Match dates (event pricing)
  - Baseline dates (same weekday, 8 weeks prior — control pricing)

Outputs: data/raw/<city_slug>_<date>_<type>.json per scrape
         data/raw/all_prices.csv  (consolidated after all runs)

Usage:
    pip install -r requirements.txt
    playwright install chromium
    python scraper/scraper.py

Notes:
    - Booking.com may prompt a CAPTCHA on first run. If blocked, set
      HEADED=1 to run with a visible browser and solve manually.
    - Rate-limited to 1 request per 4–7 seconds to respect server load.
    - Prices reflect "cheapest available" median across first 25 results
      (3-star+) to control for outlier luxury/budget properties.
"""

import asyncio
import json
import os
import random
import re
import sys
import time
from datetime import date, timedelta
from pathlib import Path

from playwright.async_api import async_playwright, TimeoutError as PWTimeout

# Allow running headed for CAPTCHA solving: HEADED=1 python scraper/scraper.py
HEADED = os.getenv("HEADED", "0") == "1"

RAW_DIR = Path(__file__).parent.parent / "data" / "raw"
RAW_DIR.mkdir(parents=True, exist_ok=True)

# Add project root to path so we can import cities
sys.path.insert(0, str(Path(__file__).parent))
from cities import CITIES


def slugify(text):
    return re.sub(r"[^a-z0-9]+", "_", text.lower()).strip("_")


def booking_url(city_query: str, checkin: date, checkout: date) -> str:
    """Build a Booking.com hotel search URL for one night."""
    base = "https://www.booking.com/searchresults.html"
    params = {
        "ss": city_query,
        "checkin": checkin.strftime("%Y-%m-%d"),
        "checkout": checkout.strftime("%Y-%m-%d"),
        "group_adults": "2",
        "no_rooms": "1",
        "nflt": "class%3D3%3Bclass%3D4%3Bclass%3D5",  # 3-star and above
        "order": "price",
    }
    return base + "?" + "&".join(f"{k}={v}" for k, v in params.items())


def extract_prices(html: str) -> list[float]:
    """
    Parse hotel prices from Booking.com search results HTML.
    Tries multiple selector patterns to handle layout changes.
    Returns a list of USD float prices.
    """
    from bs4 import BeautifulSoup

    soup = BeautifulSoup(html, "html.parser")
    prices = []

    # Pattern 1: data-testid price blocks (current layout as of 2024)
    for el in soup.select('[data-testid="price-and-discounted-price"]'):
        txt = el.get_text(strip=True)
        match = re.search(r"[\$US][\s]*([\d,]+)", txt)
        if match:
            prices.append(float(match.group(1).replace(",", "")))

    # Pattern 2: older .prco-valign-middle-helper class
    if not prices:
        for el in soup.select(".prco-valign-middle-helper"):
            txt = el.get_text(strip=True)
            match = re.search(r"([\d,]+)", txt.replace(",", ""))
            if match:
                prices.append(float(match.group(1)))

    # Pattern 3: aria-label with "US$" pattern
    if not prices:
        for el in soup.find_all(attrs={"aria-label": re.compile(r"US\$[\d,]+")}):
            match = re.search(r"US\$([\d,]+)", el.get("aria-label", ""))
            if match:
                prices.append(float(match.group(1).replace(",", "")))

    return sorted(prices)


def median_price(prices: list[float]) -> float | None:
    if not prices:
        return None
    mid = len(prices) // 2
    if len(prices) % 2 == 0:
        return (prices[mid - 1] + prices[mid]) / 2
    return prices[mid]


async def scrape_one(page, city: dict, check_date: date, label: str) -> dict:
    """Scrape one city / one date. Returns a result dict."""
    checkout = check_date + timedelta(days=1)
    url = booking_url(city["booking_query"], check_date, checkout)
    slug = slugify(city["name"])
    cache_path = RAW_DIR / f"{slug}_{check_date}_{label}.json"

    # Use cached result if already scraped
    if cache_path.exists():
        print(f"  [cache] {city['name']} {label} {check_date}")
        with open(cache_path) as f:
            return json.load(f)

    print(f"  [fetch] {city['name']} {label} {check_date} ...", end=" ", flush=True)

    result = {
        "city": city["name"],
        "country": city["country"],
        "venue": city["venue"],
        "capacity": city["capacity"],
        "matches_hosted": city["matches_hosted"],
        "date": str(check_date),
        "date_type": label,
        "url": url,
        "prices_found": [],
        "median_price": None,
        "error": None,
    }

    try:
        await page.goto(url, wait_until="domcontentloaded", timeout=20000)
        # Wait for price elements (up to 8s)
        try:
            await page.wait_for_selector(
                '[data-testid="price-and-discounted-price"], .prco-valign-middle-helper',
                timeout=8000,
            )
        except PWTimeout:
            pass  # proceed with whatever loaded

        html = await page.content()
        prices = extract_prices(html)
        result["prices_found"] = prices[:25]  # cap at 25 results
        result["median_price"] = median_price(prices[:25])
        print(f"found {len(prices)} prices, median=${result['median_price']}")

    except Exception as e:
        result["error"] = str(e)
        print(f"ERROR: {e}")

    # Cache the result
    with open(cache_path, "w") as f:
        json.dump(result, f, indent=2)

    # Polite delay: 4–8 seconds between requests
    await asyncio.sleep(random.uniform(4, 8))
    return result


async def run_scraper():
    results = []

    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=not HEADED)
        context = await browser.new_context(
            user_agent=(
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/124.0.0.0 Safari/537.36"
            ),
            locale="en-US",
            timezone_id="America/New_York",
            viewport={"width": 1280, "height": 900},
        )
        page = await context.new_page()

        # Accept cookies on first load
        await page.goto("https://www.booking.com", wait_until="domcontentloaded", timeout=15000)
        try:
            await page.click('[id="onetrust-accept-btn-handler"]', timeout=3000)
        except Exception:
            pass

        for city in CITIES:
            print(f"\n── {city['name']} ({city['country']}) ──")

            for match_date, base_date in zip(city["match_dates"], city["baseline_dates"]):
                # Scrape match date (event pricing)
                r_match = await scrape_one(page, city, match_date, "match")
                results.append(r_match)

                # Scrape baseline date (control pricing)
                r_base = await scrape_one(page, city, base_date, "baseline")
                results.append(r_base)

        await browser.close()

    # Consolidate to CSV
    import pandas as pd

    df = pd.DataFrame(results)
    out = RAW_DIR / "all_prices.csv"
    df.to_csv(out, index=False)
    print(f"\n✓ Saved {len(df)} rows → {out}")
    return df


if __name__ == "__main__":
    asyncio.run(run_scraper())
