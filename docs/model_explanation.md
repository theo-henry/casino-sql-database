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

## Assumptions and Limitations

- **Currency normalisation.** Players hold balances in their native currency
  (USD/EUR/GBP). `bet.exchange_rate_to_system` and `ticket.exchange_rate` are
  reserved for converting amounts into a single accounting currency; the
  assignment queries report native-currency totals and do not apply the rate.
- **Display widths.** Some integer columns retain MySQL's legacy display-width
  syntax (e.g. `BIGINT(20)`). These are accepted by MySQL 8 but no longer
  affect behaviour.
- **Single-payout assumption.** `bet_payout` uses `Bet_ID` as its primary key,
  meaning at most one payout row per bet. Multi-stage payouts (e.g. bonus
  unlocks) would require relaxing this constraint.
- **Soft deletes.** No `is_deleted` / `deleted_at` columns. The model assumes
  archival is handled outside the operational schema.
