# Data Quality Report

Profiling run on raw tables before any transformation.
Source: notebooks/02_profiling.ipynb

## 1. Customer identity — CRITICAL

raw_customers has 99,441 rows and 99,441 distinct customer_id,
but only 96,096 distinct customer_unique_id.

customer_id is generated per order and does not identify a person.
customer_unique_id is the true customer identifier.

**Impact:** any retention metric built on customer_id returns a repeat
rate of approximately zero. All customer-level analysis in this project
uses customer_unique_id.

**Implication for findings:** roughly 3.5% of customers place more than
one order. The repeat-buyer population is small, which limits the
statistical power of segment-level retention comparisons. Noted as a
caveat in the memo.

## 2. Date coverage — analysis window restricted

Order volume by month shows incomplete periods at both ends:

- Sep 2016: 4 orders, Oct 2016: 324, Nov 2016: absent, Dec 2016: 1
- Sep 2018: 16 orders, Oct 2018: 4 (vs 6,512 in Aug 2018)

The 2016 months reflect platform launch, not steady-state trading.
The Sep-Oct 2018 drop is a data export cut-off, not a business decline.

**Decision:** all trend analysis is restricted to 2017-01-01 through
2018-08-31. Including the tail periods would produce a false collapse
in every time series.

## 3. Date logic violations

| Check | Rows |
|---|---|
| delivered_customer_date < purchase_timestamp | 0 |
| approved_at < purchase_timestamp | 0 |
| delivered_customer_date < delivered_carrier_date | 23 |
| status = 'delivered' but delivery date is NULL | 8 |

31 rows total (0.03% of orders). Excluded from delivery-performance
calculations. Volume is too small to affect conclusions, but the
exclusion is recorded rather than silently applied.

## 4. Referential integrity

| Check | Rows |
|---|---|
| Orders with no matching customer | 0 |
| Order items with no matching order | 0 |
| Orders with no line items | 775 |

Customer and item keys join cleanly in both directions. However, 775
orders (0.78%) have no line items at all.

These are orders that exist as records but contain nothing purchased.
Any revenue calculation that joins orders to items will silently drop
these rows; any count of orders that does not join to items will include
them. The two figures will not reconcile unless the exclusion is stated.

**Decision:** revenue and delivery analysis uses only orders with at
least one line item. Order-count metrics state whether item-less orders
are included.

## 5. Order status distribution

| Status | Orders | % |
|---|---|---|
| delivered | 96,478 | 97.02 |
| shipped | 1,107 | 1.11 |
| canceled | 625 | 0.63 |
| unavailable | 609 | 0.61 |
| invoiced | 314 | 0.32 |
| processing | 301 | 0.30 |
| created | 5 | 0.01 |
| approved | 2 | 0.00 |

Only 'delivered' orders have a completed delivery journey, so
delivery-performance metrics are restricted to that status.

Retention metrics also use delivered orders only: an order that was
canceled or never fulfilled cannot reasonably be counted as a purchase
experience that would influence whether the customer returns.