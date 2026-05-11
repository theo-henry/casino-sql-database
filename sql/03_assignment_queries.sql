-- =====================================================================
-- 03_assignment_queries.sql
-- Answers to the five assignment questions.
-- Run order: 3rd (after 01_schema.sql and 02_seed_data.sql)
-- =====================================================================


-- ---------------------------------------------------------------------
-- Q1. Top 3 countries with the greatest number of players
-- ---------------------------------------------------------------------
SELECT
    ua.Country,
    COUNT(ru.User_ID) AS Total_Players
FROM registered_user ru
JOIN user_address    ua ON ru.Address_ID = ua.Address_ID
GROUP BY ua.Country
ORDER BY Total_Players DESC
LIMIT 3;


-- ---------------------------------------------------------------------
-- Q2. Top 3 demanded casino games (by number of bets placed)
-- ---------------------------------------------------------------------
SELECT
    g.Game_name,
    COUNT(b.Bet_ID) AS Total_Bets_Placed
FROM bet        b
JOIN game_round gr ON b.Round_ID = gr.Round_ID
JOIN game       g  ON gr.Game_ID = g.Game_ID
GROUP BY g.Game_name
ORDER BY Total_Bets_Placed DESC
LIMIT 3;


-- ---------------------------------------------------------------------
-- Q3. Easiest game to win (by number of bets won by players)
-- ---------------------------------------------------------------------
SELECT
    g.Game_name,
    COUNT(b.Bet_ID) AS Total_Wins
FROM bet        b
JOIN game_round gr ON b.Round_ID = gr.Round_ID
JOIN game       g  ON gr.Game_ID = g.Game_ID
WHERE b.Outcome_code = 'W'
GROUP BY g.Game_name
ORDER BY Total_Wins DESC
LIMIT 1;


-- ---------------------------------------------------------------------
-- Q4. Monthly revenue for the last 12 months
--     Revenue = sum of bets received - sum of payouts disbursed
-- ---------------------------------------------------------------------
SELECT
    DATE_FORMAT(Transaction_Date, '%Y-%m') AS Month,
    SUM(Cash_Flow) AS Net_Revenue
FROM (
    SELECT Bet_time         AS Transaction_Date,  Bet_amount     AS Cash_Flow FROM bet
    UNION ALL
    SELECT Payout_timestamp AS Transaction_Date, -Payout_amount  AS Cash_Flow FROM bet_payout
) AS Monthly_Financials
GROUP BY Month
ORDER BY Month ASC;


-- ---------------------------------------------------------------------
-- Q5. (Team question) Top 3 players generating the highest net profit
--     for the casino, and their average bet size.
-- ---------------------------------------------------------------------
SELECT
    ru.Username,
    ru.First_name,
    COUNT(b.Bet_ID)                                       AS Total_Bets_Placed,
    ROUND(AVG(b.Bet_amount), 2)                           AS Average_Bet_Size,
    (SUM(b.Bet_amount) - SUM(COALESCE(bp.Payout_amount, 0))) AS Casino_Net_Profit
FROM registered_user ru
JOIN bet             b  ON ru.User_ID = b.User_ID
LEFT JOIN bet_payout bp ON b.Bet_ID   = bp.Bet_ID
GROUP BY ru.User_ID, ru.Username, ru.First_name
ORDER BY Casino_Net_Profit DESC
LIMIT 3;
