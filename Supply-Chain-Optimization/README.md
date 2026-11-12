# Supply Chain Network Optimization (Excel Solver)

**Question:** A luxury retailer ships stock from 3 warehouses (Mumbai, Delhi, Bangalore) to 6 boutiques using proximity-based guesses. What is the cheapest shipping plan that still meets every boutique's demand?

**Slides:** [Supply Network Optimization (PDF)](https://dhruvk1310-lang.github.io/dhruvs-portfolio/decks/Dhruv-Khanna-Supply-Chain-Optimization.pdf)

## Files

| File | What it is |
|---|---|
| [`Supply-Chain-Optimization.xlsx`](./Supply-Chain-Optimization.xlsx) | The linear program in Excel Solver |
| [`Supply-Chain-Report.docx`](./Supply-Chain-Report.docx) | Written report with the network, results and sensitivity analysis |

## The model

A transportation problem with 18 decision variables (units shipped on each warehouse-to-boutique route):

- **Minimize** total freight cost: units on each route times its per-unit rate.
- **Subject to** each boutique receiving exactly its demand (430 units in total), and no warehouse shipping more than its capacity (490 units in total).
- Solved with the **Simplex LP** engine, which guarantees the optimum for a linear model.

## Results

- **Monthly cost falls from ₹2,03,800 to ₹1,36,750, a 32.9% saving**, about ₹8 lakh a year at current demand. No new warehouses or routes needed.
- **The cheapest route isn't always the cheapest plan.** Bangalore is the cheapest source for Pune, but Hyderabad and Chennai have no good alternative, so Bangalore serves them first and Pune gets only its last 10 units from there.
- **Bangalore is the binding constraint** (full at 160 units); Mumbai and Delhi have spare capacity, so extra space only pays off in Bangalore.

**Note on the numbers:** the workbook's Solver run settled at ₹1,37,250 (32.7%). Re-solving the same model exactly moves 10 of Pune's units from Mumbai to Bangalore and reaches ₹1,36,750 (32.9%), which is the figure the slides use.
