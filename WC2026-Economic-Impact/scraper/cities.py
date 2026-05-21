"""
City configuration for WC 2026 hotel price scraping.

match_dates:    3 representative match days per city (scraped for surge pricing)
baseline_dates: same day-of-week, 8 weeks before each match date (control period)

Full schedule TBD by FIFA; dates below reflect the known June 11–July 19, 2026
tournament window and host city groupings per FIFA's announcement.
Source: https://www.fifa.com/en/tournaments/mens/worldcup/canadamexicousa2026
"""

from datetime import date, timedelta

def baseline(d, weeks=8):
    """Return same weekday n weeks before match date."""
    return d - timedelta(weeks=weeks)

CITIES = [
    {
        "name": "New York / New Jersey",
        "booking_query": "Newark, New Jersey",
        "country": "USA",
        "venue": "MetLife Stadium",
        "capacity": 82500,
        "matches_hosted": 8,
        "match_dates": [date(2026, 6, 11), date(2026, 6, 18), date(2026, 7, 19)],  # opening + group + Final
    },
    {
        "name": "Los Angeles",
        "booking_query": "Los Angeles, California",
        "country": "USA",
        "venue": "SoFi Stadium",
        "capacity": 70240,
        "matches_hosted": 8,
        "match_dates": [date(2026, 6, 13), date(2026, 6, 22), date(2026, 7, 15)],  # group + Semi-Final
    },
    {
        "name": "Dallas",
        "booking_query": "Dallas, Texas",
        "country": "USA",
        "venue": "AT&T Stadium",
        "capacity": 80000,
        "matches_hosted": 7,
        "match_dates": [date(2026, 6, 12), date(2026, 6, 20), date(2026, 6, 28)],
    },
    {
        "name": "San Francisco Bay Area",
        "booking_query": "Santa Clara, California",
        "country": "USA",
        "venue": "Levi's Stadium",
        "capacity": 68500,
        "matches_hosted": 6,
        "match_dates": [date(2026, 6, 14), date(2026, 6, 21), date(2026, 6, 29)],
    },
    {
        "name": "Seattle",
        "booking_query": "Seattle, Washington",
        "country": "USA",
        "venue": "Lumen Field",
        "capacity": 68740,
        "matches_hosted": 6,
        "match_dates": [date(2026, 6, 13), date(2026, 6, 20), date(2026, 6, 27)],
    },
    {
        "name": "Miami",
        "booking_query": "Miami Gardens, Florida",
        "country": "USA",
        "venue": "Hard Rock Stadium",
        "capacity": 65326,
        "matches_hosted": 6,
        "match_dates": [date(2026, 6, 15), date(2026, 6, 22), date(2026, 6, 30)],
    },
    {
        "name": "Atlanta",
        "booking_query": "Atlanta, Georgia",
        "country": "USA",
        "venue": "Mercedes-Benz Stadium",
        "capacity": 71000,
        "matches_hosted": 6,
        "match_dates": [date(2026, 6, 14), date(2026, 6, 23), date(2026, 7, 1)],
    },
    {
        "name": "Boston",
        "booking_query": "Foxborough, Massachusetts",
        "country": "USA",
        "venue": "Gillette Stadium",
        "capacity": 65878,
        "matches_hosted": 6,
        "match_dates": [date(2026, 6, 16), date(2026, 6, 23), date(2026, 6, 30)],
    },
    {
        "name": "Houston",
        "booking_query": "Houston, Texas",
        "country": "USA",
        "venue": "NRG Stadium",
        "capacity": 72220,
        "matches_hosted": 6,
        "match_dates": [date(2026, 6, 12), date(2026, 6, 19), date(2026, 6, 26)],
    },
    {
        "name": "Philadelphia",
        "booking_query": "Philadelphia, Pennsylvania",
        "country": "USA",
        "venue": "Lincoln Financial Field",
        "capacity": 69796,
        "matches_hosted": 6,
        "match_dates": [date(2026, 6, 17), date(2026, 6, 24), date(2026, 7, 1)],
    },
    {
        "name": "Kansas City",
        "booking_query": "Kansas City, Missouri",
        "country": "USA",
        "venue": "Arrowhead Stadium",
        "capacity": 73170,
        "matches_hosted": 6,
        "match_dates": [date(2026, 6, 15), date(2026, 6, 22), date(2026, 6, 29)],
    },
    {
        "name": "Toronto",
        "booking_query": "Toronto, Ontario",
        "country": "Canada",
        "venue": "BMO Field",
        "capacity": 45000,
        "matches_hosted": 6,
        "match_dates": [date(2026, 6, 13), date(2026, 6, 21), date(2026, 6, 28)],
    },
    {
        "name": "Vancouver",
        "booking_query": "Vancouver, British Columbia",
        "country": "Canada",
        "venue": "BC Place",
        "capacity": 54500,
        "matches_hosted": 6,
        "match_dates": [date(2026, 6, 14), date(2026, 6, 20), date(2026, 6, 27)],
    },
    {
        "name": "Mexico City",
        "booking_query": "Mexico City, Mexico",
        "country": "Mexico",
        "venue": "Estadio Azteca",
        "capacity": 87523,
        "matches_hosted": 3,
        "match_dates": [date(2026, 6, 11), date(2026, 6, 17), date(2026, 6, 26)],
    },
    {
        "name": "Guadalajara",
        "booking_query": "Guadalajara, Mexico",
        "country": "Mexico",
        "venue": "Estadio Akron",
        "capacity": 49850,
        "matches_hosted": 3,
        "match_dates": [date(2026, 6, 12), date(2026, 6, 18), date(2026, 6, 25)],
    },
    {
        "name": "Monterrey",
        "booking_query": "Monterrey, Mexico",
        "country": "Mexico",
        "venue": "Estadio BBVA",
        "capacity": 53500,
        "matches_hosted": 3,
        "match_dates": [date(2026, 6, 13), date(2026, 6, 19), date(2026, 6, 24)],
    },
]

# Attach baseline dates automatically
for city in CITIES:
    city["baseline_dates"] = [baseline(d) for d in city["match_dates"]]
