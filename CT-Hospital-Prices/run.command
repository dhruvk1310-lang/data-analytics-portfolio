#!/bin/bash
# Double-click to run the full CT Hospital Price pipeline.
cd "$(dirname "$0")"

GREEN='\033[0;32m'; GOLD='\033[0;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'
BOLD='\033[1m'; NC='\033[0m'

echo ""
echo -e "${GOLD}${BOLD}🏥  CT Hospital Price Transparency Pipeline${NC}"
echo -e "${GOLD}────────────────────────────────────────────${NC}"
echo ""

# Check Python
if ! command -v python3 &>/dev/null; then
  echo -e "${RED}✗  Python 3 not found.${NC}"
  read -p "Press Enter to close..."; exit 1
fi
PYTHON=$(command -v python3)
echo -e "${GREEN}✓  Python:${NC} $($PYTHON --version)"

# Install deps
echo ""
echo -e "${BLUE}[1/3]  Installing dependencies...${NC}"
$PYTHON -m pip install -q -r scraper/requirements.txt
echo -e "${GREEN}✓  Done${NC}"

# Scrape or demo
echo ""
echo -e "${BLUE}[2/3]  Hospital price data${NC}"
echo ""

SCRAPED="data/raw/all_prices.csv"
USE_DEMO=false

if [ -f "$SCRAPED" ]; then
  ROWS=$(tail -n +2 "$SCRAPED" | wc -l | tr -d ' ')
  echo -e "  Found cached data: ${GREEN}${ROWS} rows${NC}"
  echo -e "  ${GOLD}[1]${NC} Use cached  ${GOLD}[2]${NC} Re-scrape  ${GOLD}[3]${NC} Demo data"
  read -p "  Choice [1]: " C; C=${C:-1}
  if   [ "$C" = "2" ]; then python3 scraper/scraper.py || USE_DEMO=true
  elif [ "$C" = "3" ]; then USE_DEMO=true; fi
else
  echo -e "  ${BOLD}How to get hospital price data?${NC}"
  echo -e "  ${GOLD}[1]${NC} Scrape live from CMS files (may take a few minutes)"
  echo -e "  ${GOLD}[2]${NC} Use synthetic demo data (instant)"
  read -p "  Choice [2]: " C; C=${C:-2}
  if [ "$C" = "1" ]; then
    $PYTHON scraper/scraper.py || USE_DEMO=true
  else
    USE_DEMO=true
  fi
fi

# Analysis
echo ""
echo -e "${BLUE}[3/3]  Running analysis...${NC}"
if [ "$USE_DEMO" = true ]; then
  $PYTHON analysis/analyze.py --demo
else
  $PYTHON analysis/analyze.py
fi
[ $? -ne 0 ] && { echo -e "${RED}✗  Analysis failed.${NC}"; read -p "Press Enter..."; exit 1; }

# Build Excel
echo ""
echo -e "${BLUE}      Building Excel dashboard...${NC}"
$PYTHON dashboard/create_excel.py
[ $? -ne 0 ] && { echo -e "${RED}✗  Excel build failed.${NC}"; read -p "Press Enter..."; exit 1; }

echo ""
echo -e "${GOLD}────────────────────────────────────────────${NC}"
echo -e "${GREEN}${BOLD}✓  Done! Dashboard opened in Excel.${NC}"
echo -e "${GOLD}────────────────────────────────────────────${NC}"
echo ""
read -p "Press Enter to close..."
