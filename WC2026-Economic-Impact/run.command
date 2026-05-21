#!/bin/bash
# Double-click this file on Mac to run the full pipeline and open the dashboard.

# Always run from the project directory regardless of where this file is launched from
cd "$(dirname "$0")"

# ── colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; GOLD='\033[0;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
BOLD='\033[1m'

echo ""
echo -e "${GOLD}${BOLD}⚽  FIFA World Cup 2026 — Economic Impact Pipeline${NC}"
echo -e "${GOLD}────────────────────────────────────────────────────${NC}"
echo ""

# ── check python ──────────────────────────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
  echo -e "${RED}✗  Python 3 not found. Install it from https://python.org and re-run.${NC}"
  read -p "Press Enter to close..."
  exit 1
fi
PYTHON=$(command -v python3)
echo -e "${GREEN}✓  Python:${NC} $($PYTHON --version)"

# ── install python deps ───────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}[1/4]  Installing Python dependencies...${NC}"
$PYTHON -m pip install -q -r scraper/requirements.txt
if [ $? -ne 0 ]; then
  echo -e "${RED}✗  pip install failed. Check your internet connection.${NC}"
  read -p "Press Enter to close..."; exit 1
fi
echo -e "${GREEN}✓  Dependencies ready${NC}"

# ── install playwright browsers ───────────────────────────────────────────────
echo ""
echo -e "${BLUE}[2/4]  Checking Playwright browser...${NC}"
$PYTHON -m playwright install chromium --with-deps 2>/dev/null || $PYTHON -m playwright install chromium
echo -e "${GREEN}✓  Chromium ready${NC}"

# ── scrape or demo ────────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}[3/4]  Hotel price data${NC}"
echo ""

SCRAPED_CSV="data/raw/all_prices.csv"
USE_DEMO=false

if [ -f "$SCRAPED_CSV" ]; then
  ROWS=$(tail -n +2 "$SCRAPED_CSV" | wc -l | tr -d ' ')
  echo -e "  Found existing scraped data: ${GREEN}${ROWS} records${NC}"
  echo -e "  ${BOLD}Use cached data? (recommended unless prices are stale)${NC}"
  echo -e "  ${GOLD}[1]${NC} Use cached data  ${GOLD}[2]${NC} Re-scrape  ${GOLD}[3]${NC} Use demo data"
  read -p "  Choice [1]: " CHOICE
  CHOICE=${CHOICE:-1}
  if [ "$CHOICE" = "2" ]; then
    echo ""
    echo -e "  Scraping Booking.com — this takes ~15 minutes."
    echo -e "  ${GOLD}Tip:${NC} If a CAPTCHA appears, re-run with: ${BOLD}HEADED=1 python3 scraper/scraper.py${NC}"
    echo ""
    $PYTHON scraper/scraper.py
    if [ $? -ne 0 ]; then
      echo -e "${GOLD}⚠  Scraper exited early. Running analysis on whatever was collected...${NC}"
    fi
  elif [ "$CHOICE" = "3" ]; then
    USE_DEMO=true
  fi
else
  echo -e "  No scraped data found yet."
  echo ""
  echo -e "  ${BOLD}How would you like to get hotel price data?${NC}"
  echo -e "  ${GOLD}[1]${NC} Scrape live from Booking.com (~15 min, real data)"
  echo -e "  ${GOLD}[2]${NC} Use synthetic demo data (instant, runs now)"
  read -p "  Choice [2]: " CHOICE
  CHOICE=${CHOICE:-2}
  if [ "$CHOICE" = "1" ]; then
    echo ""
    echo -e "  Starting scraper. Booking.com is scraped politely (4–8s between requests)."
    echo -e "  ${GOLD}Tip:${NC} If a CAPTCHA appears, re-run with: ${BOLD}HEADED=1 python3 scraper/scraper.py${NC}"
    echo ""
    $PYTHON scraper/scraper.py
    if [ $? -ne 0 ]; then
      echo -e "${GOLD}⚠  Scraper hit an issue. Falling back to demo data.${NC}"
      USE_DEMO=true
    fi
  else
    USE_DEMO=true
  fi
fi

# ── run analysis ──────────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}[4/4]  Running analysis (pandas / scipy / sklearn)...${NC}"
echo ""
if [ "$USE_DEMO" = true ]; then
  $PYTHON analysis/analyze.py --demo
else
  $PYTHON analysis/analyze.py
fi

if [ $? -ne 0 ]; then
  echo -e "${RED}✗  Analysis failed. See error above.${NC}"
  read -p "Press Enter to close..."; exit 1
fi

echo ""
echo -e "${GREEN}${BOLD}✓  Analysis complete${NC}"

# ── start server and open browser ────────────────────────────────────────────
echo ""
echo -e "${GOLD}────────────────────────────────────────────────────${NC}"
echo -e "${GREEN}${BOLD}  Launching dashboard at http://localhost:8080/dashboard/${NC}"
echo -e "${GOLD}────────────────────────────────────────────────────${NC}"
echo ""
echo -e "  Press ${BOLD}Ctrl+C${NC} to stop the server when done."
echo ""

# Kill any process already using port 8080
lsof -ti:8080 | xargs kill -9 2>/dev/null

# Open browser after a short delay to let the server start
(sleep 1.5 && open "http://localhost:8080/dashboard/") &

# Start server (blocks until Ctrl+C)
$PYTHON -m http.server 8080
