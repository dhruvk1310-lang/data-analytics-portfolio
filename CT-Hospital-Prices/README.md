# Connecticut Hospital Price Detective

Scrapes CMS-mandated price transparency files from 5 Connecticut hospitals,
compares the same 20 procedures across all of them, and outputs a formatted Excel dashboard.

## The finding
Same MRI. Same CPT code. $400 at one hospital. $3,200 at another.
This is legal, documented, and almost nobody knows about it.

## Hospitals
| Hospital | System | City |
|----------|--------|------|
| Yale New Haven Hospital | Yale New Haven Health | New Haven |
| Hartford Hospital | Hartford HealthCare | Hartford |
| UConn Health | University of Connecticut | Farmington |
| Stamford Hospital | Yale New Haven Health | Stamford |
| Bridgeport Hospital | Yale New Haven Health | Bridgeport |

## Procedures tracked (20 CPT codes)
Imaging (MRI, CT, X-Ray, Echo), Lab (CBC, metabolic panel, HbA1c),
ED visits (Level 4 & 5), and major procedures (colonoscopy, knee replacement, mammogram).

## How to run
Double-click `run.command` — it installs deps, scrapes, analyzes, and opens Excel.

Or manually:
```bash
pip install -r scraper/requirements.txt
python scraper/scraper.py          # or --demo for synthetic data
python analysis/analyze.py
python dashboard/create_excel.py
```

## Excel workbook — 4 sheets
| Sheet | Contents |
|-------|----------|
| Dashboard | KPI cards + bar chart (top price gaps) |
| By Procedure | All 20 procedures × 5 hospitals, color-coded |
| By Hospital | Per-hospital price profile + overall rankings |
| Raw Data | Long-format clean data for your own pivot tables |

## Data source
CMS 45 CFR 180 — Hospital Price Transparency rule (effective Jan 2021).
All US hospitals required to publish machine-readable price files.
