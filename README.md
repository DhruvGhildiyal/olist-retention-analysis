# Why repeat purchase is falling at a growing marketplace

An analysis of 96,184 delivered orders (Jan 2017 – Aug 2018) answering a stakeholder question about declining retention.

**[Read the memo →](docs/03_memo.md)**

---

## The brief

This project starts from a request, not a dataset. A Head of Operations believes repeat purchase is falling, Marketing blames fulfilment, and Operations says delivery is fine. Nobody has checked.

Full brief: [docs/00_stakeholder_brief.md](docs/00_stakeholder_brief.md)

*(The brief is a constructed scenario. The data is real.)*

---

## What the analysis found

**The premise was wrong.** Revenue nearly tripled over the period (+180%). Average order value is flat. All growth came from new customers.

**Retention never existed to decline.** The 90-day repeat rate ran at ~2.1% in 2017 and ~1.9% in 2018 — weak throughout. The business is an acquisition engine, not a customer base.

**Late delivery clearly damages satisfaction.** Going from on-promise to one day late triples 1-star reviews (8.4% → 25.2%). Delivering ten days early scores barely better than one day early — the return is in not missing the promise, not in speed.

**Whether it damages retention is unproven.** Late-delivery customers returned at 1.02% vs 1.32% for on-time — right direction, but p = 0.062. The recommendation rests on the satisfaction evidence instead.

**The problem is concentrated.** 82 sellers handle 17% of order volume and produce 32% of all late deliveries.

---

## Dashboard

<img width="940" height="530" alt="image" src="https://github.com/user-attachments/assets/61b816c4-604a-4196-8d5b-0282968e0e8e" />

<img width="940" height="530" alt="image" src="https://github.com/user-attachments/assets/a6d1e3cb-f5e4-460d-b860-5e8464441fe5" />

Built in Power BI. Source file: `dashboard/olist_retention.pbix`

---

## Repo structure
docs/
00_stakeholder_brief.md the request
01_data_quality_report.md what was wrong with the data
02_metric_definitions.md how every metric is defined
03_memo.md the deliverable
sql/
01_build_schema.sql star schema build
notebooks/
01_load.ipynb raw ingest
02_profiling.ipynb data quality checks
03_build_schema.ipynb schema build + validation tests
04_analysis.ipynb analysis
outputs/dashboard/ aggregated CSVs feeding the dashboard

## Running it

```bash
pip install duckdb pandas scipy
# place the 9 Olist CSVs in data/raw/
# run notebooks in order
```

Data: [Olist Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (not committed to this repo).

Raw tables are never modified. Every cleaning decision creates a new table, so any result traces back to source.

---

## What I got wrong

**The seller Pareto, first attempt.** I ranked sellers by count of late deliveries and found 3.4% of sellers caused 50% of late orders. That looked strong until I checked the same sellers' share of total orders: 41%. The concentration was a volume effect, not a performance one. I re-ran it on late *rate* with a minimum-volume threshold, which is the version reported.

**Cohort retention, first attempt.** My initial cohort table showed repeat rates collapsing to near zero by mid-2018. They weren't — those cohorts hadn't had time to return before the data ends. Cohorts without a complete observation window are now reported as null rather than zero.

**Two different late-order counts.** Platform-level analysis showed 6,531 late orders, seller-level showed 6,518. I traced the gap to 13 multi-seller orders excluded from seller attribution rather than reporting whichever number suited the section.

---

## What this analysis cannot answer

- Whether late delivery reduces retention (directional, not statistically significant)
- Whether acquisition-led growth is sustainable (no marketing spend data)
- Which seller caused a delay on multi-seller orders (1.3% of orders)
- How estimated delivery dates are set — which the main recommendation depends on

---

## Data handling

- Analysis window restricted to Jan 2017 – Aug 2018; periods outside are incomplete and would show a false collapse
- `customer_unique_id` used for all customer-level work, not `customer_id`, which is generated per order
- 3,257 orders (3.3%) excluded; every exclusion documented in the data quality report
- 8 automated validation tests run after schema build; the pipeline fails rather than producing untested output

---

## Tools

DuckDB, SQL, Python (pandas, scipy), Power BI
