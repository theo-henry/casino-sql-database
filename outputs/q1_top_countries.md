# Q1 — Top 3 Countries by Number of Players

**Question:** Which are the top 3 countries with the greatest number of players?

**Query:** see [`sql/03_assignment_queries.sql`](../sql/03_assignment_queries.sql) — Q1.

The query uses `DENSE_RANK() ≤ 3` rather than `LIMIT 3` so that ties at the
top three ranks are returned in full and the result is deterministic.

## Result

| Country | total_players |
|---------|--------------:|
| USA     | 3             |
| Canada  | 2             |
| UK      | 2             |

## Notes

- USA leads with 3 registered players (User IDs 1, 2, 3).
- Canada and UK are tied at 2 players each. Both are returned because they
  occupy rank 2 by `DENSE_RANK`; their order is broken alphabetically.
- Germany and France each have 1 player (rank 3) and fall outside the
  top-three threshold.
