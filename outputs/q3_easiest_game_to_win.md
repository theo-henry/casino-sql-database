# Q3 — Easiest Game to Win

**Question:** Which is the easiest game to win, by number of bets won by players?

**Query:** see [`sql/03_assignment_queries.sql`](../sql/03_assignment_queries.sql) — Q3.

The query uses `RANK() OVER (ORDER BY total_wins DESC)` and filters
`rnk = 1`, so a true tie at first place returns every winner instead of
silently dropping one.

## Result

| Game_name                      | total_wins |
|--------------------------------|-----------:|
| Grankie Dettori’s Black Jack   | 3          |
| Low Stakes Blackjack           | 3          |

## Notes

- Both blackjack titles are tied with 3 winning bets each and share the
  top rank.
- Treating either one as a unique "winner" would be misleading; the
  tie-aware query exposes both, which is the correct business answer.
