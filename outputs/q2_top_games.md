# Q2 — Top 3 Most Demanded Casino Games

**Question:** Which are the top 3 demanded casino games (by number of bets placed)?

**Query:** see [`sql/03_assignment_queries.sql`](../sql/03_assignment_queries.sql) — Q2.

`DENSE_RANK() ≤ 3` keeps every game tied within the top three ranks.

## Result

| Game_name                      | total_bets_placed |
|--------------------------------|------------------:|
| Grankie Dettori’s Black Jack   | 4                 |
| Irish Riches                   | 4                 |
| Low Stakes Blackjack           | 3                 |

## Notes

- *Grankie Dettori’s Black Jack* and *Irish Riches* are tied for first
  place at 4 bets each.
- Blackjack as a category dominates demand: both the flagship table game
  and the low-stakes variant make the top three.
