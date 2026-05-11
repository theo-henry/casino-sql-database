-- =====================================================================
-- 04_validation_checks.sql
-- Sanity / integrity checks after loading schema and seed data.
-- Run order: 4th (after 01_schema.sql, 02_seed_data.sql, optionally 03)
--
-- Every check below returns rows ONLY when something is wrong, except
-- the row-count block which always reports counts for inspection.
-- =====================================================================


-- ---------------------------------------------------------------------
-- Row counts of every main table (visual sanity check)
-- ---------------------------------------------------------------------
SELECT 'user_status'             AS table_name, COUNT(*) AS row_count FROM user_status
UNION ALL SELECT 'user_gender',             COUNT(*) FROM user_gender
UNION ALL SELECT 'kyc_document_type',       COUNT(*) FROM kyc_document_type
UNION ALL SELECT 'kyc_verification_status', COUNT(*) FROM kyc_verification_status
UNION ALL SELECT 'address_type',            COUNT(*) FROM address_type
UNION ALL SELECT 'currency',                COUNT(*) FROM currency
UNION ALL SELECT 'cc_payment_type',         COUNT(*) FROM cc_payment_type
UNION ALL SELECT 'cc_payment_state',        COUNT(*) FROM cc_payment_state
UNION ALL SELECT 'bet_outcome_type',        COUNT(*) FROM bet_outcome_type
UNION ALL SELECT 'game_type',               COUNT(*) FROM game_type
UNION ALL SELECT 'ticket_type',             COUNT(*) FROM ticket_type
UNION ALL SELECT 'zip_code',                COUNT(*) FROM zip_code
UNION ALL SELECT 'user_address',            COUNT(*) FROM user_address
UNION ALL SELECT 'registered_user',         COUNT(*) FROM registered_user
UNION ALL SELECT 'kyc_document',            COUNT(*) FROM kyc_document
UNION ALL SELECT 'game',                    COUNT(*) FROM game
UNION ALL SELECT 'game_round',              COUNT(*) FROM game_round
UNION ALL SELECT 'cc_payment',              COUNT(*) FROM cc_payment
UNION ALL SELECT 'cc_payment_card',         COUNT(*) FROM cc_payment_card
UNION ALL SELECT 'ticket',                  COUNT(*) FROM ticket
UNION ALL SELECT 'bet',                     COUNT(*) FROM bet
UNION ALL SELECT 'bet_payout',              COUNT(*) FROM bet_payout;


-- ---------------------------------------------------------------------
-- Integrity check 1: every winning bet must have a payout row
-- (Outcome_code = 'W' implies bet_payout entry)
-- ---------------------------------------------------------------------
SELECT b.Bet_ID, b.User_ID, b.Bet_amount, b.Outcome_code
FROM bet b
LEFT JOIN bet_payout bp ON b.Bet_ID = bp.Bet_ID
WHERE b.Outcome_code = 'W'
  AND bp.Bet_ID IS NULL;


-- ---------------------------------------------------------------------
-- Integrity check 2: no payout should exist for a losing bet
-- ---------------------------------------------------------------------
SELECT b.Bet_ID, b.Outcome_code, bp.Payout_amount
FROM bet b
JOIN bet_payout bp ON b.Bet_ID = bp.Bet_ID
WHERE b.Outcome_code = 'L';


-- ---------------------------------------------------------------------
-- Integrity check 3: payout amount must be > bet amount when a win pays
-- (Catches data-entry slips like a "win" that pays back less than staked.)
-- ---------------------------------------------------------------------
SELECT b.Bet_ID, b.Bet_amount, bp.Payout_amount
FROM bet b
JOIN bet_payout bp ON b.Bet_ID = bp.Bet_ID
WHERE bp.Payout_amount < b.Bet_amount;


-- ---------------------------------------------------------------------
-- Integrity check 4: every player must have at least one KYC document
-- ---------------------------------------------------------------------
SELECT ru.User_ID, ru.Username
FROM registered_user ru
LEFT JOIN kyc_document kd ON ru.User_ID = kd.User_ID
WHERE kd.KYC_doc_ID IS NULL;


-- ---------------------------------------------------------------------
-- Integrity check 5: bets must occur within their game round's window
-- ---------------------------------------------------------------------
SELECT b.Bet_ID, b.Bet_time, gr.Start_time, gr.End_time
FROM bet b
JOIN game_round gr ON b.Round_ID = gr.Round_ID
WHERE b.Bet_time < gr.Start_time
   OR b.Bet_time > gr.End_time;


-- ---------------------------------------------------------------------
-- Integrity check 6: bet amount must be within the game's min/max range
-- ---------------------------------------------------------------------
SELECT b.Bet_ID, g.Game_name, b.Bet_amount, g.Min_bet_amount, g.Max_bet_amount
FROM bet b
JOIN game_round gr ON b.Round_ID = gr.Round_ID
JOIN game       g  ON gr.Game_ID = g.Game_ID
WHERE b.Bet_amount < g.Min_bet_amount
   OR b.Bet_amount > g.Max_bet_amount;
