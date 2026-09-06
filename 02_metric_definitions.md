# Metric Definitions

Every metric in this project is defined here before it is calculated.
Any filter applied in SQL traces back to a rule on this page.

## Analysis window

2017-01-01 to 2018-08-31.
Periods outside this range are incomplete (see Data Quality Report, §2).

## Customer

A customer is a `customer_unique_id`, not a `customer_id`.
`customer_id` is generated per order and does not identify a person
(Data Quality Report, §1).

## Valid order

An order counts toward analysis if it meets all of:
- `order_status = 'delivered'`
- has at least one row in `raw_order_items`
- `order_purchase_timestamp` falls within the analysis window
- passes the date-logic checks in Data Quality Report §3

Rationale: only delivered orders represent a completed purchase
experience capable of influencing whether a customer returns.

## Order revenue

Sum of `price` + `freight_value` across all line items on the order.

Payments data is not used for revenue. `raw_payments` records how the
order was paid, including installments, and can be split across multiple
rows per order — summing it double-counts.

## Repeat customer

A customer with 2 or more valid orders within the analysis window.

## Repeat rate (cohort)

For a cohort of customers who placed their first valid order in month M,
the repeat rate at N days is:

  customers with a second valid order within N days of their first
  ---------------------------------------------------------------
  all customers whose first valid order was in month M

Measured at 30, 60 and 90 days.

Cohorts are only included if the full N-day window falls inside the
analysis period. A customer whose first order was in August 2018 has no
90-day window available and is excluded from the 90-day figure.

## Delivery lateness

Late = `order_delivered_customer_date` > `order_estimated_delivery_date`.

Days late = date difference between the two, in whole days.
Early or on-time deliveries are recorded as 0 days late, not negative,
when computing average lateness.

The estimated date is the promise shown to the customer, so it is the
correct benchmark for measuring customer experience. Actual transit
time is a separate operational metric and is not used here.

## Seller attribution

98.7% of orders (97,388) contain items from a single seller. Only 1,278
orders involve more than one seller.

For single-seller orders, delivery performance is attributed cleanly to
that seller.

For the 1.3% multi-seller orders, the data records one delivery date per
order rather than per shipment, so it is not possible to identify which
seller caused a delay. These orders are excluded from seller-level
lateness rankings and included only in company-wide figures.

At 1.3% of volume this exclusion does not materially affect the seller
ranking, and removing the ambiguity is preferable to attributing a delay
to a seller who may not have caused it.

## Review score

`review_score` from `raw_reviews`, scale 1 to 5.

547 orders (0.55%) carry more than one review. Of these, 202 have
differing scores — the customer's rating changed between submissions.

**Rule:** the earliest review by `review_creation_date` is used.

**Rationale:** this analysis tests whether the delivery experience
influences repeat purchase behaviour, so the rating closest in time to
delivery is the relevant signal. A later revised score may reflect a
refund, replacement or support interaction that occurred after the
delivery event being measured.

**Sensitivity:** the affected population is 0.2% of orders. Substituting
the latest or the mean score would not change any conclusion in this
analysis. The rule is stated for reproducibility, not because it is
material.