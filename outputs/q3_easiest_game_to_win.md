# Q3 — Easiest Game to Win

**Question:** Which is the easiest game to win, by number of bets won by players?

**Query:** see [`sql/03_assignment_queries.sql`](../sql/03_assignment_queries.sql) — Q3.

## Result

| Game_name                      | Total_Wins |
|--------------------------------|-----------:|
| Grankie Dettori’s Black Jack   | 3          |

## Notes

- *Grankie Dettori’s Black Jack* and *Low Stakes Blackjack* both have 3 winning bets
  in the seed data. `LIMIT 1` returns whichever the engine emits first; on the
  reference dataset this is *Grankie Dettori’s Black Jack*.
- For a tie-safe answer, swap `LIMIT 1` for a `DENSE_RANK()` window or a `HAVING`
  clause against the max win count — both Blackjack titles tie for "easiest to win."

## Full tie-breakdown

| Game_name                      | Total_Wins |
|--------------------------------|-----------:|
| Grankie Dettori’s Black Jack   | 3          |
| Low Stakes Blackjack           | 3          |
