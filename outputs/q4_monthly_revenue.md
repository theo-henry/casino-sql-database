# Q4 — Monthly Revenue (Last 12 Months)

**Question:** Show a linear graph of revenue for the last 12 months.

**Query:** see [`sql/03_assignment_queries.sql`](../sql/03_assignment_queries.sql) — Q4.

Revenue is modelled as the **net cash flow from gaming activity**:
`SUM(bet_amount)` (inflow) minus `SUM(payout_amount)` (outflow), grouped by month.

## Result

| Month    | Net_Revenue |
|----------|------------:|
| 2024-01  |     0.00    |
| 2024-02  |    40.00    |
| 2024-03  |   200.00    |
| 2024-04  |  -100.00    |
| 2024-05  |   -40.00    |
| 2024-06  |    10.00    |
| 2024-07  |    50.00    |
| 2024-08  |  -200.00    |
| 2024-09  |    50.00    |
| 2024-10  |  1000.00    |
| 2024-11  |   -25.00    |
| 2024-12  |   150.00    |

**Total net revenue across the period: 1,135.00**

## Notes

- Negative months correspond to periods where payouts to winners exceeded total
  bets staked (e.g. April 2024: one large winning bet paid out 200 against
  100 in bets).
- October 2024 is the strongest single month, driven by a 1,000-stake losing
  bet from user `royal_bet_uk` on Premier League Betting.
- The query is currency-agnostic by design — see the *Assumptions & Limitations*
  section of [`docs/model_explanation.md`](../docs/model_explanation.md).
