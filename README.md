# Online Casino — MySQL Database

A normalised MySQL database for a regulated online casino, built for an assignment in my SQL based data architectures course. The repository contains the full ERD, schema DDL, sample data, and analytical queries that answer five business questions about players, games, and revenue.

---

## Overview

This project models the operational backbone of an online casino: player
identity, KYC compliance, wallet ledger, card payments, game catalogue, game
rounds, bets, and payouts. The schema is normalised to **3NF** and engineered
so that the bet ledger can absorb high transaction volume without disrupting
the banking ledger.

The repository is fully reproducible: load three SQL files in order and every
query result in [`outputs/`](outputs/) can be regenerated against the seed
data.

## Business Context

Online casinos operate under strict regulatory pressure — KYC, anti-money
laundering, transaction traceability, and game-fairness auditability are all
mandatory. The data model is shaped by those requirements:

- **Identity & KYC** are first-class entities, not afterthought columns.
- **Money movement** (`ticket`, `cc_payment`, `cc_payment_card`) is decoupled
  from **gaming activity** (`bet`, `bet_payout`) so that high-frequency play
  cannot disturb the banking ledger.
- **Game fairness** is auditable via per-round RNG seeds on `game_round`.

## Database Design Summary

22 tables organised into five domains:

| Domain        | Tables                                                                                 |
|---------------|----------------------------------------------------------------------------------------|
| Lookups       | `user_status`, `user_gender`, `kyc_document_type`, `kyc_verification_status`, `address_type`, `currency`, `cc_payment_type`, `cc_payment_state`, `bet_outcome_type`, `game_type`, `ticket_type` |
| Location      | `zip_code`, `user_address`                                                             |
| Player & KYC  | `registered_user`, `kyc_document`                                                      |
| Payments      | `cc_payment`, `cc_payment_card`, `ticket`                                              |
| Gaming        | `game`, `game_round`, `bet`, `bet_payout`                                              |

The full design rationale, including normalisation choices and assumptions,
lives in [`docs/model_explanation.md`](docs/model_explanation.md).

## Repository Structure

```
casino-sql-database/
├── README.md
├── LICENSE
├── .gitignore
├── erd/
│   └── SQLII_casino_group4.mwb       # MySQL Workbench ERD (open in Workbench)
├── sql/
│   ├── 01_schema.sql                 # DDL: tables, keys, constraints
│   ├── 02_seed_data.sql              # Sample data (INSERTs, FK-safe order)
│   ├── 03_assignment_queries.sql     # The five business questions
│   └── 04_validation_checks.sql      # Row counts + integrity checks
├── outputs/
│   ├── q1_top_countries.md
│   ├── q2_top_games.md
│   ├── q3_easiest_game_to_win.md
│   ├── q4_monthly_revenue.md
│   └── q5_top_profitable_players.md
└── docs/
    └── model_explanation.md
```

## How to Run

**Prerequisites:** MySQL Server 8.0+ and MySQL Workbench.

1. **Inspect the ERD.** Open `erd/SQLII_casino_group4.mwb` in MySQL Workbench
   (*File → Open Model*).
2. **Create a schema** in Workbench or via the CLI:
   ```sql
   CREATE DATABASE casino;
   USE casino;
   ```
3. **Run the SQL files in order**, either via Workbench's *Run SQL Script*
   dialog or from the command line:
   ```bash
   mysql -u <user> -p casino < sql/01_schema.sql
   mysql -u <user> -p casino < sql/02_seed_data.sql
   mysql -u <user> -p casino < sql/03_assignment_queries.sql
   mysql -u <user> -p casino < sql/04_validation_checks.sql
   ```
4. **Compare results** against the Markdown tables in [`outputs/`](outputs/).

## Assignment Questions Answered

| # | Question                                                                 | Output                                                   |
|---|--------------------------------------------------------------------------|----------------------------------------------------------|
| 1 | Top 3 countries with the greatest number of players                      | [q1_top_countries.md](outputs/q1_top_countries.md)       |
| 2 | Top 3 most-demanded casino games                                         | [q2_top_games.md](outputs/q2_top_games.md)               |
| 3 | Easiest game to win, by number of bets won                               | [q3_easiest_game_to_win.md](outputs/q3_easiest_game_to_win.md) |
| 4 | Monthly revenue for the last 12 months                                   | [q4_monthly_revenue.md](outputs/q4_monthly_revenue.md)   |
| 5 | **(Custom)** Top 3 players by casino net profit and their average bet    | [q5_top_profitable_players.md](outputs/q5_top_profitable_players.md) |

## Tools Used

- **MySQL 8.0** — relational database engine
- **MySQL Workbench** — ERD design (`.mwb`) and schema execution
- **Git / GitHub** — version control

## Key Skills Demonstrated

- Relational modelling and normalisation to **3NF**
- Schema design for a regulated, compliance-heavy domain (KYC, AML
  traceability, RNG-seed retention for fairness audits)
- Production-grade DDL: `InnoDB` + `utf8mb4`, `AUTO_INCREMENT` surrogate
  keys, `DATETIME` event timestamps, named foreign keys, composite
  analytical indexes
- Domain invariants encoded as `CHECK` constraints (positive amounts,
  coherent date windows, valid bet-range ordering, non-negative balances)
- Foreign-key-safe DDL ordering, idempotent `DROP TABLE` reloads, and
  reproducible data seeding
- Analytical SQL with **CTEs** and **window functions** (`RANK`,
  `DENSE_RANK`) for deterministic, tie-aware Top-N queries
- Multi-currency ledger logic via `bet.exchange_rate_to_system`,
  applied to monthly revenue and per-player profit
- Trailing-window analytics anchored on `MAX(txn_date)` so reports stay
  meaningful regardless of when the data was loaded
- Defensive query design (`COALESCE` for missing payouts, `UNION ALL`
  cash-flow ledgers, separation of stake inflows from payout outflows)
- Standalone integrity-check queries that complement the schema-level
  constraints
- Portfolio-grade documentation of design rationale, engineering
  decisions, and remaining assumptions

## License

[MIT](LICENSE)
