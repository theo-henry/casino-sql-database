# Q5 — Top 3 Players by Casino Net Profit (FX-Normalised)

**Question:** Who are the top 3 players generating the highest net profit
for the casino, and what is their average bet size?

**Query:** see [`sql/03_assignment_queries.sql`](../sql/03_assignment_queries.sql) — Q5.

Casino net profit per player =
`SUM(bet_amount × FX) − SUM(COALESCE(payout_amount, 0) × FX)`,
where `FX = bet.exchange_rate_to_system`.

## Result

| Username       | First_name | total_bets_placed | avg_bet_sys_ccy | casino_net_profit_sys_ccy |
|----------------|------------|------------------:|----------------:|--------------------------:|
| royal_bet_uk   | Elizabeth  | 1                 | 1250.00         | 1250.00                   |
| maple_bet      | Sarah      | 2                 |  175.00         |  350.00                   |
| vegas_mike     | Mike       | 2                 |   35.00         |   70.00                   |

## Notes

- *royal_bet_uk* is a single-bet outlier: one 1,000-stake loss on
  Premier League Betting at FX 1.25 normalises to 1,250 in system
  currency.
- *maple_bet* shows a more typical high-roller pattern — multiple losses
  at triple-digit average stakes.
- All amounts are reported in the casino's accounting currency. Cross-
  currency comparison is meaningful here because the FX rate is folded
  into every aggregate.
