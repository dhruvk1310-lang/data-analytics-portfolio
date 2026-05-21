"""
Connecticut hospital configuration.
Each entry includes the price transparency landing page and known
machine-readable file URL patterns. The scraper tries the direct URL
first, then falls back to scraping the landing page for a download link.

CMS requires all US hospitals to publish machine-readable price files
under 45 CFR 180. Sources:
  - https://www.cms.gov/hospital-price-transparency
  - Individual hospital transparency pages (verified May 2026)
"""

HOSPITALS = [
    {
        "name": "Yale New Haven Hospital",
        "short": "YNHH",
        "system": "Yale New Haven Health",
        "city": "New Haven",
        "beds": 1541,
        "landing_page": "https://www.ynhh.org/patients-visitors/billing/price-transparency",
        "direct_url": "https://www.ynhh.org/media/ynhh-standard-charges.json",
        "alt_urls": [
            "https://www.ynhh.org/media/ynhh-standard-charges.csv",
        ],
        "file_format": "json",  # cms_json | csv | zip
    },
    {
        "name": "Hartford Hospital",
        "short": "HH",
        "system": "Hartford HealthCare",
        "city": "Hartford",
        "beds": 867,
        "landing_page": "https://hartfordhealthcare.org/patients-visitors/billing/price-transparency",
        "direct_url": "https://hartfordhealthcare.org/media/standard-charges/hartford-hospital-standard-charges.json",
        "alt_urls": [
            "https://hartfordhealthcare.org/media/standard-charges/hartford-hospital-standard-charges.csv",
        ],
        "file_format": "json",
    },
    {
        "name": "UConn Health",
        "short": "UCH",
        "system": "University of Connecticut",
        "city": "Farmington",
        "beds": 263,
        "landing_page": "https://health.uconn.edu/billing/price-transparency/",
        "direct_url": "https://health.uconn.edu/wp-content/uploads/uconn-health-standard-charges.csv",
        "alt_urls": [
            "https://health.uconn.edu/wp-content/uploads/uconn-health-standard-charges.json",
        ],
        "file_format": "csv",
    },
    {
        "name": "Stamford Hospital",
        "short": "SH",
        "system": "Yale New Haven Health",
        "city": "Stamford",
        "beds": 305,
        "landing_page": "https://www.stamfordhealth.org/patients-visitors/billing/price-transparency/",
        "direct_url": "https://www.stamfordhealth.org/media/standard-charges/stamford-hospital-standard-charges.json",
        "alt_urls": [
            "https://www.stamfordhealth.org/media/standard-charges/stamford-hospital-standard-charges.csv",
        ],
        "file_format": "json",
    },
    {
        "name": "Bridgeport Hospital",
        "short": "BH",
        "system": "Yale New Haven Health",
        "city": "Bridgeport",
        "beds": 383,
        "landing_page": "https://www.bridgeporthospital.org/patients-visitors/billing/price-transparency",
        "direct_url": "https://www.bridgeporthospital.org/media/standard-charges/bridgeport-hospital-standard-charges.json",
        "alt_urls": [
            "https://www.bridgeporthospital.org/media/standard-charges/bridgeport-hospital-standard-charges.csv",
        ],
        "file_format": "json",
    },
]

# CPT codes to extract and compare — high-impact, common procedures
# Format: code -> (short label, category, description)
TARGET_CPTS = {
    # Imaging
    "70553": ("MRI Brain",         "Imaging",    "MRI Brain w/o & w/ contrast"),
    "70450": ("CT Head",           "Imaging",    "CT Head/Brain w/o contrast"),
    "74177": ("CT Abd/Pelvis",     "Imaging",    "CT Abdomen & Pelvis w/ contrast"),
    "71046": ("Chest X-Ray",       "Imaging",    "Chest X-ray 2 views"),
    "72148": ("MRI Lumbar",        "Imaging",    "MRI Lumbar Spine w/o contrast"),
    "93306": ("Echocardiogram",    "Imaging",    "Transthoracic echocardiogram"),
    # Lab
    "85025": ("CBC",               "Lab",        "Complete blood count w/ differential"),
    "80048": ("Metabolic Panel",   "Lab",        "Basic metabolic panel"),
    "83036": ("HbA1c",             "Lab",        "Hemoglobin A1c"),
    "82565": ("Creatinine",        "Lab",        "Creatinine blood test"),
    "36415": ("Blood Draw",        "Lab",        "Venipuncture / blood draw"),
    # Emergency / Outpatient Visits
    "99284": ("ED Visit Lvl 4",    "ED Visit",   "Emergency dept visit, moderate severity"),
    "99285": ("ED Visit Lvl 5",    "ED Visit",   "Emergency dept visit, high severity"),
    "99213": ("Office Visit",      "Office",     "Established patient office visit, low complexity"),
    # Procedures
    "45378": ("Colonoscopy",       "Procedure",  "Colonoscopy, diagnostic"),
    "77067": ("Mammogram",         "Procedure",  "Screening mammogram, bilateral"),
    "93000": ("EKG",               "Procedure",  "Electrocardiogram w/ interpretation"),
    "27447": ("Knee Replacement",  "Procedure",  "Total knee arthroplasty"),
    "27130": ("Hip Replacement",   "Procedure",  "Total hip arthroplasty"),
    "43239": ("Upper Endoscopy",   "Procedure",  "EGD w/ biopsy"),
}
