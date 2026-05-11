# Q5 — Top 3 Players by Casino Net Profit (Custom Question)

**Question:** Who are the top 3 players generating the highest net profit for the
casino, and what is their average bet size?

**Query:** see [`sql/03_assignment_queries.sql`](../sql/03_assignment_queries.sql) — Q5.

Casino net profit per player =
`SUM(bet_amount) − SUM(COALESCE(payout_amount, 0))`.

## Result

| Username       | First_name  | Total_Bets_Placed | Average_Bet_Size | Casino_Net_Profit |
|----------------|-------------|------------------:|-----------------:|------------------:|
| royal_bet_uk   | Elizabeth   | 1                 | 1000.00          | 1000.00           |
| maple_bet      | Sarah       | 2                 |  175.00          |  350.00           |
| vegas_mike     | Mike        | 2                 |   35.00          |   70.00           |

## Notes

- *royal_bet_uk* is a single-bet outlier: one 1,000-stake loss on Premier League
  Betting drives the entire net profit contribution.
- *maple_bet* shows a more typical high-roller signature — multiple losses at
  triple-digit average stakes.
- Currencies are reported as native amounts (no FX normalisation applied).
  The `bet.exchange_rate_to_system` column is reserved for that conversion in a
  production extension of this query.
