# Q1 — Top 3 Countries by Number of Players

**Question:** Which are the top 3 countries with the greatest number of players?

**Query:** see [`sql/03_assignment_queries.sql`](../sql/03_assignment_queries.sql) — Q1.

## Result

| Country | Total_Players |
|---------|--------------:|
| USA     | 3             |
| Canada  | 2             |
| UK      | 2             |

## Notes

- USA leads with 3 registered players (User IDs 1, 2, 3).
- Canada and UK are tied at 2 players each. MySQL's `ORDER BY Total_Players DESC LIMIT 3`
  returns both; their relative order on a tie is implementation-defined.
- Germany and France each have 1 player and fall outside the top 3.
