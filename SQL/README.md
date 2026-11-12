# IBM HR Attrition Analysis (SQL)

**Question:** 16.1% of employees left. Which ones, and what can HR change?

Ten MySQL queries on IBM's HR Analytics attrition dataset: 1,470 employees and 35 variables covering pay, role, satisfaction and whether they left.

**Slides:** [IBM HR Attrition Analysis (PDF)](https://dhruvk1310-lang.github.io/dhruvs-portfolio/decks/Dhruv-Khanna-IBM-HR-Attrition.pdf)

## Files

| File | What it is |
|---|---|
| [`IBMHR.sql`](./IBMHR.sql) | The ten queries, each answering one business question |
| [`HR.csv`](./HR.csv) | The dataset |
| [`IBM_HR_Analytics_Report.docx`](./IBM_HR_Analytics_Report.docx) | Written report with findings and recommendations |

## Key findings

- **Overtime is the strongest single driver:** 30.5% of overtime workers left (127 of 416), against 10.4% of everyone else (110 of 1,054).
- **Under-25s leave at 39.2%**, nearly four times the 35 to 44 group (10.1%).
- **Sales has the highest attrition** at 20.6%; R&D, the largest department, has the lowest at 13.8%.
- **Satisfaction halves attrition:** a score of 1 leaves at 22.8%, a score of 4 at 11.3%.
- **The three lowest-paid roles** (Research Scientist, Laboratory Technician, Sales Representative) sit in the highest-attrition departments.

These turn into six recommendations, from monitoring overtime in Sales to moving pay growth into an employee's first five years.

## Techniques

`GROUP BY` aggregation, conditional `SUM` to count leavers, `CASE WHEN` age bands, multi-column segmentation and compound `WHERE` filters for a flight-risk profile.

## Running it

1. Strip the UTF-8 byte-order mark from `HR.csv` (it breaks the MySQL Workbench import).
2. Import it into a schema called `ibm_hr` as a table called `HR`.
3. Run the queries in `IBMHR.sql`.

**Limits:** IBM built this dataset for teaching, and it's a single snapshot, so the results show association, not cause.
