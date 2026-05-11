# Q4 — Monthly Net Revenue (Trailing 12 Months, FX-Normalised)

**Question:** Show monthly revenue for the last 12 months.

**Query:** see [`sql/03_assignment_queries.sql`](../sql/03_assignment_queries.sql) — Q4.

Net revenue per month is the **FX-normalised cash flow from gaming
activity**: stakes received minus payouts disbursed, each priced at the
bet's `exchange_rate_to_system`. Payouts inherit their parent bet's rate so
that wins and losses settle in the same currency.

The 12-month window is anchored on the latest ledger event in the data
(`MAX(txn_date)`), which keeps the window meaningful regardless of when
the seed data was loaded. Replace the anchor with `CURRENT_DATE` for
wall-clock production semantics.

## Result

| month   | net_revenue_sys_ccy |
|---------|--------------------:|
| 2024-01 |     0.00            |
| 2024-02 |    40.00            |
| 2024-03 |   200.00            |
| 2024-04 |  -100.00            |
| 2024-05 |   -44.00            |
| 2024-06 |    10.00            |
| 2024-07 |    50.00            |
| 2024-08 |  -200.00            |
| 2024-09 |    50.00            |
| 2024-10 |  1250.00            |
| 2024-11 |   -25.00            |
| 2024-12 |   150.00            |

**Total net revenue across the window: 1,381.00 (system currency).**

## Notes

- Negative months reflect periods where payouts to winners exceeded total
  stakes (e.g. April 2024: a 100 stake produced a 200 payout).
- October 2024 is the strongest single month, driven by user
  `royal_bet_uk`'s 1,000-stake losing bet on Premier League Betting,
  normalised to 1,250 in system currency at FX 1.25.
- May 2024 shifts from −40 (raw) to −44 (FX) because the bet from user
  `london_player` was placed at FX 1.20.
