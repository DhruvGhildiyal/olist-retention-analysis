# Repeat purchase decline: what the data shows

**To:** Head of Operations
**From:** Data Analyst
**Date:** [date]
**Data:** 96,184 delivered orders, Jan 2017 – Aug 2018

---

## Recommendation

Put 82 sellers on a 90-day on-time improvement programme with a defined
exit threshold. They handle 17% of order volume but produce 32% of all
late deliveries, and their customers file 1-star reviews at 1.5x the
rate of everyone else.

Bringing them to the platform average would remove roughly 800 late
deliveries over a comparable 20-month period — about 11% of all late
deliveries. This is achievable: the top decile of sellers runs at a
0.8% late rate on similar volume.

---

## The premise in the brief is wrong

The brief assumed a revenue problem. There isn't one.

| | H1 2017 | H1 2018 | Change |
|---|---|---|---|
| Monthly customers | 2,280 | 6,469 | +184% |
| Orders per customer | 1.021 | 1.009 | −1.2% |
| Average order value | 163.75 | 163.65 | −0.1% |
| Monthly revenue | 381,019 | 1,067,810 | +180% |

Revenue nearly tripled. Basket size is flat. All growth came from new
customers.

The real issue is that **retention was never there to decline**. The
90-day repeat rate ran at roughly 2.1% through 2017 and 1.9% in 2018 —
weak throughout, not deteriorating from a healthy base. The business
has built an acquisition engine, not a customer base.

This distinction matters: fixing a decline means restoring something
that worked. This requires building something that has never existed.

---

## Delivery performance drives satisfaction — clearly

| Delivery vs promise | Orders | Avg review | 1-star % |
|---|---|---|---|
| 10+ days early | 61,252 | 4.33 | 6.4% |
| On promise | 1,280 | 4.04 | 8.4% |
| 1–3 days late | 1,851 | 3.29 | **25.2%** |
| 4–7 days late | 1,748 | 2.11 | 58.5% |
| 8–14 days late | 1,446 | 1.67 | 70.6% |

Two things stand out.

**The cliff is at day one.** Going from on-promise to one day late
triples 1-star reviews. Delivering ten days early scores barely better
than delivering one day early (4.33 vs 4.23).

**Implication:** there is no return on making delivery faster. The
return is entirely in not missing the promised date. If estimates are
currently set optimistically, widening them costs almost nothing and
removes most of the damage.

The relationship is monotonic across all buckets, which is difficult to
explain by anything other than delivery driving the rating.

---

## Delivery performance and retention — unresolved

| First order | Customers | Returned in 90d |
|---|---|---|
| On time | 69,420 | 1.32% |
| Late | 5,694 | 1.02% |

The direction is as expected — a 23% relative reduction — but this is
**not statistically significant** (chi-square = 3.49, p = 0.062). Only
58 customers in the late group returned at all. The sample cannot
separate a real effect from chance.

**This is why the recommendation above rests on satisfaction, not
retention.** At a platform-wide repeat rate near 1%, detecting a
retention effect would require a longer observation window or a
controlled test. Both are recommended as follow-ups.

I have not attached a revenue figure to the recommendation for this
reason. One could be constructed, but it would not be defensible.

---

## Where the problem sits

Sellers ranked by late rate (minimum 50 orders):

| | Sellers | % of orders | % of late deliveries | Late rate | Avg review |
|---|---|---|---|---|---|
| Best decile | 42 | 5.4% | 0.7% | 0.8% | 4.33 |
| Bottom 2 deciles | 82 | 17.2% | 32.1% | 11–16% | 3.89 |

Customers of the bottom 82 file 1-star reviews at 15.2% versus 9.8%
elsewhere.

82 accounts is small enough for individual management.

---

## What this analysis cannot tell you

- **Whether late delivery reduces retention.** Directionally yes,
  statistically unproven. See above.
- **Whether growth is sustainable.** No marketing spend or acquisition
  cost data was available, so the economics of acquisition-led growth
  cannot be assessed.
- **Which seller caused a delay on multi-seller orders.** The data
  records one delivery date per order. Affects 1.3% of orders; these
  are excluded from seller rankings.
- **Why estimates are set where they are.** The estimated delivery date
  is treated as given. Whether it is a system default, a seller input
  or a calculation is not visible in this data, and the "widen the
  promise" recommendation depends on that.

---

## Suggested next steps

1. Confirm how estimated delivery dates are generated. If adjustable,
   test widening them for the bottom 82 sellers.
2. Instrument a proper retention test — hold out a group, measure over
   180 days.
3. Obtain acquisition cost data. The growth model's viability is the
   larger question and cannot be answered without it.

---

### Notes on figures

Late order counts appear as 6,531 platform-wide and 6,518 in
seller-level analysis. The difference is 13 multi-seller orders,
excluded from seller attribution. Seller-level figures therefore cover
98.7% of order volume.

3,257 orders (3.3%) were excluded as undelivered, cancelled, item-less
or failing date-logic checks. See docs/01_data_quality_report.md.
