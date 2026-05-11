# Data Model Explanation

This document walks through the logical reasoning behind the casino data model,
in the chronological order the design was constructed. The schema is normalised
to **3NF** and built around the operational realities of a regulated online
casino: identity, compliance, money movement, and game integrity.

## 1. The Player as the Anchor Entity

The design starts with the player. `registered_user` is the central entity that
every other relationship hangs off.

Storing volatile descriptions such as account status (*Active*, *Banned*) or
gender directly on the user row would create redundancy and update anomalies.
Both were extracted into the lookup tables `user_status` and `user_gender`. A
description change now happens once, in one row, and propagates system-wide.

## 2. Location and Address Logic

A free-text address is unfit for a real platform that needs geolocation for
legal compliance. Address data lives in `user_address`, separated from account
data.

Within an address, `City` and `State` are functionally dependent on the ZIP
code, not on the specific address. Storing them on every address row would
introduce a transitive dependency. The dedicated `zip_code` table acts as the
single source of truth for the city, state, and country tied to each code,
keeping `user_address` in 3NF.

## 3. KYC and Compliance

Online casinos operate under strict Know-Your-Customer regulation. Identity
documents are modelled as their own entity — `kyc_document` — rather than
columns on the user. A player might upload a passport today and a driver's
licence next year; row-per-document handles that naturally.

The model is normalised further with `kyc_document_type` (standardised document
categories) and `kyc_verification_status` (the approval workflow). The result
is a clean audit trail: when each document was submitted, when it was
verified, and its current validity — all without bloating the user profile.

## 4. The Financial Ledger

Money management is deliberately split from gameplay. `ticket` is the wallet
ledger: every distinct financial event (deposit, withdrawal) is one ticket row.

Fund processing lives in `cc_payment`. Card-level details (encrypted card
number, issuing bank) are attributes of the *card*, not the transaction, so
they live in `cc_payment_card`. This keeps `cc_payment` lightweight (a record
of success or failure) while isolating sensitive card data in a separate table
that can be locked down independently.

## 5. The Game Engine

The product hierarchy starts at `game_type` — Slots, Blackjack, Roulette,
Poker, and so on. `game` holds the per-title configuration including minimum
and maximum bet limits.

A bet is never an isolated action; it occurs within a specific context.
`game_round` represents that context: a single slot spin or a single blackjack
hand. The round captures start and end times and the RNG seed — essential
data for fairness audits.

`bet` links a player to a round and is deliberately decoupled from `ticket`.
High-frequency betting would otherwise overwhelm the banking ledger.

Outcomes are split into `bet_payout` so that a bet can be recorded as an
immediate financial inflow while the payout (if any) is a conditional outflow.
Losses are represented simply by the absence of a payout row — which makes the
Gross Gaming Revenue calculation a single `LEFT JOIN`.

## Engineering Choices

- **Engine and charset.** Every table is `ENGINE = InnoDB` with
  `DEFAULT CHARSET = utf8mb4` so that game names with non-ASCII characters
  (curly apostrophes, accented letters) round-trip safely, and so that
  foreign-key constraints are honoured.
- **DATETIME over TIMESTAMP.** Event timestamps use `DATETIME` rather than
  `TIMESTAMP`: no implicit timezone conversion, no 2038 ceiling, and no
  surprise auto-initialisation rules.
- **AUTO_INCREMENT surrogate keys.** All synthetic primary keys are
  auto-incrementing; explicit seed IDs still load cleanly under InnoDB,
  which advances the counter to the largest inserted value.
- **CHECK constraints.** Domain invariants are encoded in the schema —
  positive bet and payout amounts, coherent date windows on game rounds
  and KYC verification, valid bet-range ordering on each game, and
  non-negative wallet balances. Violations cannot be inserted, regardless
  of application bugs.
- **Analytical indexes.** Composite indexes back the access patterns used
  by the assignment queries (`bet(User_ID, Bet_time)`, `bet(Bet_time)`,
  `game_round(Game_ID, Start_time)`, `kyc_document(User_ID, Status_code)`).
- **Phone numbers as strings.** `Phone_number` is `VARCHAR(20)` to
  preserve leading zeros, country-code prefixes, and formatting.

## Assumptions and Limitations

- **Single-payout assumption.** `bet_payout` uses `Bet_ID` as its primary
  key, so at most one payout row per bet. Multi-stage payouts (bonus
  unlocks, side-bet wins) would require relaxing this constraint.
- **FX rate sourced from the bet.** Payouts inherit their parent bet's
  `exchange_rate_to_system`, which is correct for in-play settlement but
  ignores hold-period drift. A production system would either snapshot a
  rate on the payout row or post FX-revaluation adjustments separately.
- **Soft deletes.** No `is_deleted` / `deleted_at` columns. Archival is
  assumed to happen outside the operational schema.
- **ISO codes.** `Issuing_country` uses `CHAR(2)` but accepts non-ISO
  values (`'UK'` rather than `'GB'`) to match the rest of the dataset.
  A stricter design would reference an ISO 3166-1 lookup table.
