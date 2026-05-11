-- =====================================================================
-- 03_assignment_queries.sql
-- Analytical queries answering the five business questions.
-- Run order: 3rd (after 01_schema.sql and 02_seed_data.sql).
-- Requires: MySQL 8.0+ (window functions, CTEs).
--
-- Design notes:
--   * Top-N queries use DENSE_RANK / RANK rather than LIMIT so that ties
--     are returned deterministically (no implementation-defined ordering).
--   * Monetary aggregates apply bet.exchange_rate_to_system to normalise
--     multi-currency cash flows into the casino's accounting currency.
--   * "Last 12 months" is anchored on the most recent ledger event so the
--     window is meaningful regardless of when the seed data was loaded.
--     To switch to wall-clock semantics, replace the anchor CTE with
--         SELECT CURRENT_DATE AS anchor.
-- =====================================================================

SET NAMES utf8mb4;


-- ---------------------------------------------------------------------
-- Q1. Top 3 countries by number of players (ties included).
-- ---------------------------------------------------------------------
WITH country_counts AS (
    SELECT
        ua.Country,
        COUNT(*)                                   AS total_players,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
    FROM registered_user ru
    JOIN user_address    ua ON ru.Address_ID = ua.Address_ID
    GROUP BY ua.Country
)
SELECT Country, total_players
FROM country_counts
WHERE rnk <= 3
ORDER BY total_players DESC, Country ASC;


-- ---------------------------------------------------------------------
-- Q2. Top 3 most-demanded games by bets placed (ties included).
-- ---------------------------------------------------------------------
WITH game_demand AS (
    SELECT
        g.Game_name,
        COUNT(*)                                   AS total_bets_placed,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
    FROM bet         b
    JOIN game_round  gr ON b.Round_ID = gr.Round_ID
    JOIN game        g  ON gr.Game_ID = g.Game_ID
    GROUP BY g.Game_name
)
SELECT Game_name, total_bets_placed
FROM game_demand
WHERE rnk <= 3
ORDER BY total_bets_placed DESC, Game_name ASC;


-- ---------------------------------------------------------------------
-- Q3. Easiest game(s) to win, by number of bets won.
--     RANK() returns every game tied for first place — no silent winner.
-- ---------------------------------------------------------------------
WITH wins_per_game AS (
    SELECT
        g.Game_name,
        COUNT(*)                              AS total_wins,
        RANK() OVER (ORDER BY COUNT(*) DESC)  AS rnk
    FROM bet        b
    JOIN game_round gr ON b.Round_ID = gr.Round_ID
    JOIN game       g  ON gr.Game_ID = g.Game_ID
    WHERE b.Outcome_code = 'W'
    GROUP BY g.Game_name
)
SELECT Game_name, total_wins
FROM wins_per_game
WHERE rnk = 1
ORDER BY Game_name ASC;


-- ---------------------------------------------------------------------
-- Q4. Net gaming revenue per month for the trailing 12 months,
--     FX-normalised to the system accounting currency.
--
--     Revenue = SUM(stake) − SUM(payout), each priced at the bet's
--     exchange_rate_to_system. Payouts inherit their parent bet's rate.
-- ---------------------------------------------------------------------
WITH cash_flows AS (
    SELECT
        b.Bet_time                                                            AS txn_date,
        ROUND(b.Bet_amount * b.exchange_rate_to_system, 2)                    AS cash_flow_sys_ccy
    FROM bet b
    UNION ALL
    SELECT
        bp.Payout_timestamp                                                   AS txn_date,
        ROUND(-bp.Payout_amount * b.exchange_rate_to_system, 2)               AS cash_flow_sys_ccy
    FROM bet_payout bp
    JOIN bet        b ON bp.Bet_ID = b.Bet_ID
),
window_anchor AS (
    SELECT MAX(txn_date) AS anchor FROM cash_flows
)
SELECT
    DATE_FORMAT(cf.txn_date, '%Y-%m') AS month,
    ROUND(SUM(cf.cash_flow_sys_ccy), 2) AS net_revenue_sys_ccy
FROM cash_flows  cf
CROSS JOIN window_anchor w
WHERE cf.txn_date >= DATE_SUB(w.anchor, INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(cf.txn_date, '%Y-%m')
ORDER BY month ASC;


-- ---------------------------------------------------------------------
-- Q5. Top 3 most profitable players for the casino,
--     with their average bet size — all amounts FX-normalised.
-- ---------------------------------------------------------------------
WITH player_pnl AS (
    SELECT
        ru.User_ID,
        ru.Username,
        ru.First_name,
        COUNT(b.Bet_ID)                                                              AS total_bets_placed,
        ROUND(AVG(b.Bet_amount * b.exchange_rate_to_system), 2)                       AS avg_bet_sys_ccy,
        ROUND(
            SUM(b.Bet_amount * b.exchange_rate_to_system)
          - SUM(COALESCE(bp.Payout_amount, 0) * b.exchange_rate_to_system),
            2
        )                                                                             AS casino_net_profit_sys_ccy
    FROM registered_user ru
    JOIN bet             b  ON ru.User_ID = b.User_ID
    LEFT JOIN bet_payout bp ON b.Bet_ID   = bp.Bet_ID
    GROUP BY ru.User_ID, ru.Username, ru.First_name
)
SELECT
    Username,
    First_name,
    total_bets_placed,
    avg_bet_sys_ccy,
    casino_net_profit_sys_ccy
FROM player_pnl
ORDER BY casino_net_profit_sys_ccy DESC, Username ASC
LIMIT 3;
