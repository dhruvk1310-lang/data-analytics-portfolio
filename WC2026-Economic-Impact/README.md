# FIFA World Cup 2026 — Hotel Surge & Economic Impact Analysis

A real data pipeline that scrapes live hotel prices from Booking.com, runs statistical analysis in Python, and visualizes results in an interactive dashboard.

## What it does

1. **Scrapes** hotel nightly rates from Booking.com for all 16 WC 2026 host cities on match dates vs. baseline dates (same weekday, 8 weeks prior)
2. **Calculates** hotel surge % per city using scraped medians
3. **Runs** Pearson correlations and OLS regression (matches hosted + venue capacity → surge %, economic impact)
4. **Outputs** a dashboard-ready JSON, a clean CSV, and 4 matplotlib figures
5. **Visualizes** everything in an interactive Chart.js dashboard

## Project Structure

```
WC2026-Economic-Impact/
├── scraper/
│   ├── cities.py          # City config: venues, match dates, baseline dates
│   ├── scraper.py         # Playwright scraper (Booking.com, headless Chrome)
│   └── requirements.txt   # Python dependencies
├── analysis/
│   └── analyze.py         # pandas/numpy/scipy/sklearn analysis pipeline
├── data/
│   ├── raw/               # Per-city JSON + all_prices.csv (scraper output)
│   └── processed/
│       ├── surge_analysis.csv      # Main output
│       ├── dashboard_data.json     # Dashboard-ready JSON
│       └── figures/               # 4 PNG charts
├── dashboard/
│   └── index.html         # Interactive dashboard (reads dashboard_data.json)
└── report/
    └── executive_report.docx
```

## Setup

```bash
pip install -r scraper/requirements.txt
playwright install chromium
```

## Run the pipeline

```bash
# Step 1: Scrape hotel prices from Booking.com
python scraper/scraper.py

# Step 2: Run analysis
python analysis/analyze.py

# Step 3: Serve the dashboard
python -m http.server 8080
# Open: http://localhost:8080/dashboard/
```

## Demo mode (no scraping required)

Preview the dashboard with synthetic data while waiting for real prices:

```bash
python analysis/analyze.py --demo
python -m http.server 8080
```

## Scraper notes

- Uses **Playwright** (headless Chromium) to handle JavaScript-rendered prices
- **Rate-limited** to 4–8 seconds between requests
- Results are **cached** per city/date in `data/raw/` — re-runs are instant
- If Booking.com shows a CAPTCHA, run with `HEADED=1 python scraper/scraper.py` to solve it in a visible browser window
- Scrapes 3-star+ hotels, 2 adults, 1 room, sorted by price, median of first 25 results

## Analysis outputs

| File | Contents |
|------|----------|
| `data/processed/surge_analysis.csv` | Per-city: baseline median, match median, surge %, correlates |
| `data/processed/dashboard_data.json` | All of the above + regression results + country summary |
| `data/processed/figures/surge_bar.png` | Hotel surge % ranked bar chart |
| `data/processed/figures/scatter_regression.png` | Baseline rate vs surge % with OLS fit |
| `data/processed/figures/impact_vs_matches.png` | Matches hosted vs economic impact bubble chart |
| `data/processed/figures/country_comparison.png` | USA / Canada / Mexico side-by-side |

## Key findings (from synthetic demo data — update after scraping)

- **Highest surge %**: New York/New Jersey (+125%) hosting 8 matches including the Final
- **Highest peak rate**: San Francisco Bay Area ($455/night) due to $230 baseline amplified by +98% surge
- **Biggest outlier**: Mexico City — +110% surge from only 3 matches (Azteca historic demand)
- **R² = 0.84**: matches hosted + ln(venue capacity) explains 84% of economic impact variance

## Tech stack

- Python 3.11+
- playwright, beautifulsoup4, pandas, numpy, scipy, scikit-learn, matplotlib
- Chart.js 4.5 (dashboard)
- python-docx (report)
