-- =====================================================================
-- 02_seed_data.sql
-- Sample data for the Online Casino schema (DML)
-- Run order: 2nd (after 01_schema.sql, before 03_assignment_queries.sql)
-- Inserts are ordered to respect foreign-key dependencies.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Lookup tables
-- ---------------------------------------------------------------------

INSERT INTO user_status (Status_code, Description) VALUES
    ('A', 'Active'),
    ('B', 'Banned'),
    ('P', 'Pending');

INSERT INTO user_gender (Gender_code, Description) VALUES
    ('M', 'Male'),
    ('F', 'Female'),
    ('O', 'Other');

INSERT INTO kyc_document_type (Doc_type_code, Description) VALUES
    ('PAS', 'Passport'),
    ('DL',  'Drivers License'),
    ('ID',  'National ID');

INSERT INTO kyc_verification_status (Status_code, Description) VALUES
    ('P', 'Pending'),
    ('V', 'Verified'),
    ('R', 'Rejected');

INSERT INTO address_type (Type_ID, Description) VALUES
    (1, 'Street'),
    (2, 'Avenue'),
    (3, 'Boulevard'),
    (4, 'Road');

INSERT INTO currency (Currency_ID, Currency_Code, Description) VALUES
    ('USD', 840, 'US Dollar'),
    ('EUR', 978, 'Euro'),
    ('GBP', 826, 'British Pound');

INSERT INTO bet_outcome_type (Outcome_code, Description) VALUES
    ('W', 'Win'),
    ('L', 'Loss'),
    ('P', 'Push/Tie');

INSERT INTO game_type (Game_type_code, Description) VALUES
    ('SLT', 'Slots'),
    ('BLK', 'Blackjack'),
    ('ROL', 'Roulette'),
    ('POK', 'Poker'),
    ('CRP', 'Craps'),
    ('LIV', 'Live game'),
    ('KEN', 'Keno'),
    ('SPT', 'Sports Betting');

INSERT INTO ticket_type (TType_ID, Type_Name, Description) VALUES
    (1, 'Deposit',    'User loads wallet'),
    (2, 'Withdrawal', 'User cashes out');

INSERT INTO cc_payment_type (CCType, Description) VALUES
    ('VS', 'Visa'),
    ('MC', 'MasterCard'),
    ('AM', 'American Express');

INSERT INTO cc_payment_state (CCState, Description) VALUES
    ('0', 'State_new'),
    ('1', 'State_approving'),
    ('2', 'State_approved'),
    ('3', 'State_failed'),
    ('4', 'State_cancelled'),
    ('5', 'State_expired');

-- ---------------------------------------------------------------------
-- Location
-- ---------------------------------------------------------------------

INSERT INTO zip_code (ZIP_code, Country, City, State) VALUES
    (100001, 'USA',     'New York',      'NY'),
    (902140, 'USA',     'Beverly Hills', 'CA'),
    (552778, 'Canada',  'Toronto',       'ON'),
    (992876, 'UK',      'London',        'England'),
    (101155, 'Germany', 'Berlin',        'Berlin'),
    (750011, 'France',  'Paris',         'Ile-de-France');

INSERT INTO user_address (Address_ID, Type_ID, Address_Number, ZIP_code, Country) VALUES
    (101, 2, 12, 100001, 'USA'),
    (102, 1, 45, 100001, 'USA'),
    (103, 3, 88, 902140, 'USA'),
    (104, 4, 10, 552778, 'Canada'),
    (105, 1, 22, 552778, 'Canada'),
    (106, 1,  5, 992876, 'UK'),
    (107, 1,  7, 992876, 'UK'),
    (108, 1, 99, 101155, 'Germany'),
    (109, 3,  1, 750011, 'France');

-- ---------------------------------------------------------------------
-- Players
-- ---------------------------------------------------------------------

INSERT INTO registered_user
    (User_ID, Status_code, Username, First_name, Last_name, Email, Phone_number, Address_ID,
     Passkey, Date_of_birth, Gender_code, Registration_date, Currency_ID, Account_balance)
VALUES
    (1, 'A', 'pokerface_usa',  'John',      'Doe',     'john@usa.com',   15550101,  101, 'hash123', '1990-01-01', 'M', '2023-01-01 10:00:00', 'USD',   500.00),
    (2, 'A', 'slot_queen_usa', 'Jane',      'Smith',   'jane@usa.com',   15550102,  102, 'hash123', '1992-05-15', 'F', '2023-02-01 11:00:00', 'USD',  1200.50),
    (3, 'A', 'vegas_mike',     'Mike',      'Ross',    'mike@usa.com',   15550103,  103, 'hash123', '1985-08-20', 'M', '2023-03-01 12:00:00', 'USD',    50.00),
    (4, 'A', 'maple_bet',      'Sarah',     'Connor',  'sarah@ca.com',  141655501,  104, 'hash123', '1995-12-12', 'F', '2023-04-01 09:30:00', 'USD',   300.00),
    (5, 'A', 'toronto_king',   'Drake',     'Graham',  'drake@ca.com',  141655502,  105, 'hash123', '1988-10-10', 'M', '2023-05-01 14:20:00', 'USD',  5000.00),
    (6, 'A', 'london_player',  'James',     'Bond',    'james@uk.com',  442079460,  106, 'hash123', '1980-07-07', 'M', '2023-06-01 16:45:00', 'GBP',   150.00),
    (7, 'A', 'royal_bet_uk',   'Elizabeth', 'Windsor', 'liz@uk.com',    442079461,  107, 'hash123', '1950-04-21', 'F', '2023-07-01 08:00:00', 'GBP', 10000.00),
    (8, 'A', 'berlin_pro',     'Hans',      'Mueller', 'hans@de.com',   493012345,  108, 'hash123', '1991-09-09', 'M', '2023-08-01 18:00:00', 'EUR',   200.00),
    (9, 'A', 'paris_luck',     'Pierre',    'Curie',   'pierre@fr.com', 331234567,  109, 'hash123', '1993-03-03', 'M', '2023-09-01 19:15:00', 'EUR',     0.00);

-- ---------------------------------------------------------------------
-- KYC documents
-- ---------------------------------------------------------------------

INSERT INTO kyc_document
    (KYC_doc_ID, User_ID, Doc_type_code, Document_number, Issuing_country,
     Issue_date, Expiry_date, Status_code, Submitted_timestamp, Verified_timestamp)
VALUES
    (901, 1, 'PAS', 'US123456789',  'US', '2020-01-01', '2030-01-01', 'V', '2023-01-02 10:00:00', '2023-01-03 10:00:00'),
    (902, 2, 'DL',  'NY-987654321', 'US', '2021-05-15', '2025-05-15', 'V', '2023-02-02 11:00:00', '2023-02-03 11:00:00'),
    (903, 3, 'ID',  'US-ID-555666', 'US', '2022-08-20', '2032-08-20', 'P', '2023-03-02 12:00:00', NULL),
    (904, 4, 'PAS', 'CA987654321',  'CA', '2019-12-12', '2029-12-12', 'V', '2023-04-02 09:30:00', '2023-04-03 09:30:00'),
    (905, 5, 'DL',  'ON-11223344',  'CA', '2021-10-10', '2026-10-10', 'V', '2023-05-02 14:20:00', '2023-05-03 14:20:00'),
    (906, 6, 'PAS', 'UK112233445',  'UK', '2018-07-07', '2028-07-07', 'V', '2023-06-02 16:45:00', '2023-06-03 16:45:00'),
    (907, 7, 'DL',  'UK-DL-998877', 'UK', '2020-04-21', '2030-04-21', 'V', '2023-07-02 08:00:00', '2023-07-03 08:00:00'),
    (908, 8, 'ID',  'DE-ID-123456', 'DE', '2021-09-09', '2031-09-09', 'V', '2023-08-02 18:00:00', '2023-08-03 18:00:00'),
    (909, 9, 'PAS', 'FR998877665',  'FR', '2022-03-03', '2032-03-03', 'R', '2023-09-02 19:15:00', '2023-09-03 19:15:00');

-- ---------------------------------------------------------------------
-- Games & rounds
-- ---------------------------------------------------------------------

INSERT INTO game (Game_ID, Game_name, Game_type_code, Min_bet_amount, Max_bet_amount) VALUES
    ( 1, 'Grankie Dettori’s Black Jack', 'BLK',  5.00,  500.00),
    ( 2, 'American Roulette',            'ROL',  1.00, 1000.00),
    ( 3, 'Irish Riches',                 'SLT',  0.20,  100.00),
    ( 4, 'Low Stakes Blackjack',         'BLK',  1.00,   50.00),
    ( 5, 'Aces & Faces',                 'POK',  0.25,   50.00),
    ( 6, 'Mega Moolah Slots',            'SLT',  0.50,  100.00),
    ( 7, 'Live Baccarat',                'LIV', 10.00, 2000.00),
    ( 8, 'Craps Classic',                'CRP',  5.00,  500.00),
    ( 9, 'Super Keno',                   'KEN',  1.00,  100.00),
    (10, 'Premier League Betting',       'SPT',  1.00, 5000.00);

INSERT INTO game_round (Round_ID, Game_ID, Start_time, End_time, Random_number_generator_seed) VALUES
    (1001,  1, '2024-01-15 10:00:00', '2024-01-15 10:00:05', 12345),
    (1002,  3, '2024-02-14 14:00:00', '2024-02-14 14:02:00', 67890),
    (1003,  2, '2024-03-20 20:00:00', '2024-03-20 20:01:00', 11111),
    (1004,  1, '2024-04-10 09:00:00', '2024-04-10 09:00:05', 22222),
    (1005,  4, '2024-05-05 18:30:00', '2024-05-05 18:32:00', 33333),
    (1006,  5, '2024-06-15 11:00:00', '2024-06-15 11:00:05', 44444),
    (1007,  8, '2024-07-04 22:00:00', '2024-07-04 22:02:00', 55555),
    (1008,  1, '2024-08-12 15:00:00', '2024-08-12 15:03:00', 66666),
    (1009,  3, '2024-09-01 08:00:00', '2024-09-01 08:00:10', 77777),
    (1010, 10, '2024-10-31 23:00:00', '2024-10-31 23:05:00', 88888),
    (1011,  4, '2024-11-11 16:00:00', '2024-11-11 16:02:00', 99999),
    (1012,  3, '2024-12-25 10:00:00', '2024-12-25 10:00:05', 10101);

-- ---------------------------------------------------------------------
-- Payments (inserted before tickets that reference them)
-- ---------------------------------------------------------------------

INSERT INTO cc_payment
    (CCPayment_ID, CCPaytran_ID, User_ID, Currency_ID, Expected_amount,
     Approving_amount, Approved_amount, CCPayment_state, Timecreated)
VALUES
    (801, 9001, 1, 'USD',  1000.00,  1000.00,  1000.00, '2', '2024-01-01 09:00:00'),
    (802, 9002, 5, 'USD',  5000.00,  5000.00,  5000.00, '2', '2024-05-01 10:00:00'),
    (803, 9003, 3, 'USD',   200.00,   200.00,   200.00, '2', '2024-03-01 11:00:00'),
    (804, 9004, 4, 'USD',   300.00,   300.00,   300.00, '2', '2024-04-01 12:00:00'),
    (805, 9005, 5, 'USD',  5000.00,  5000.00,  5000.00, '2', '2024-05-01 13:00:00'),
    (806, 9006, 6, 'GBP',   150.00,   150.00,   150.00, '2', '2024-06-01 14:00:00'),
    (807, 9007, 7, 'GBP', 10000.00, 10000.00, 10000.00, '2', '2024-07-01 15:00:00'),
    (808, 9008, 8, 'EUR',   200.00,   200.00,   200.00, '2', '2024-08-01 16:00:00'),
    (809, 9009, 9, 'EUR',   100.00,   100.00,   100.00, '3', '2024-09-01 17:00:00');

INSERT INTO cc_payment_card (CCPayment_ID, Payment_Type, Is_encrypt, Card_number, Bankname, CCExpdate) VALUES
    (801, 'VS', 'Y', '4111xxxxxxxx1111', 'Chase Bank',      '1225'),
    (802, 'MC', 'Y', '5100xxxxxxxx2222', 'Bank of America', '1124'),
    (803, 'AM', 'Y', '3782xxxxxxxx0005', 'Amex Centurion',  '0926'),
    (804, 'VS', 'Y', '4500xxxxxxxx3333', 'RBC Royal Bank',  '0527'),
    (805, 'MC', 'Y', '5500xxxxxxxx0055', 'TD Bank',         '0626'),
    (806, 'VS', 'Y', '4222xxxxxxxx4444', 'Barclays',        '0825'),
    (807, 'MC', 'Y', '5444xxxxxxxx8888', 'HSBC UK',         '0128'),
    (808, 'VS', 'Y', '4333xxxxxxxx9999', 'Deutsche Bank',   '1026'),
    (809, 'MC', 'Y', '5222xxxxxxxx7777', 'BNP Paribas',     '0325');

-- ---------------------------------------------------------------------
-- Tickets (wallet ledger)
-- ---------------------------------------------------------------------

INSERT INTO ticket
    (Ticket_ID, User_ID, Currency_ID, Ticket_timestamp, TType_ID,
     Payment_ID, Reference_ID, Amount, exchange_rate)
VALUES
    (701, 1, 'USD', '2024-01-01 09:05:00', 1, 801, 801, 1000.00, 1.0),
    (702, 5, 'USD', '2024-05-01 10:05:00', 1, 802, 802, 5000.00, 1.0);

-- ---------------------------------------------------------------------
-- Bets & payouts
-- ---------------------------------------------------------------------

INSERT INTO bet
    (Bet_ID, Round_ID, User_ID, Bet_amount, Bet_time, Outcome_code, exchange_rate_to_system)
VALUES
    (501, 1001, 1,   50.00, '2024-01-15 10:00:00', 'L', 1.00),
    (502, 1001, 2,   50.00, '2024-01-15 10:00:01', 'W', 1.00),
    (503, 1002, 3,   20.00, '2024-02-14 14:00:00', 'L', 1.00),
    (504, 1002, 1,   20.00, '2024-02-14 14:00:10', 'L', 1.00),
    (505, 1003, 4,  200.00, '2024-03-20 20:00:00', 'L', 1.00),
    (506, 1004, 2,  100.00, '2024-04-10 09:00:00', 'W', 1.00),
    (507, 1005, 5,   20.00, '2024-05-05 18:30:00', 'W', 1.00),
    (508, 1005, 6,   20.00, '2024-05-05 18:31:00', 'W', 1.20),
    (509, 1006, 1,   10.00, '2024-06-15 11:00:00', 'L', 1.00),
    (510, 1007, 3,   50.00, '2024-07-04 22:00:00', 'L', 1.00),
    (511, 1008, 1,  200.00, '2024-08-12 15:00:00', 'W', 1.00),
    (512, 1009, 2,   50.00, '2024-09-01 08:00:00', 'L', 1.00),
    (513, 1010, 7, 1000.00, '2024-10-31 23:00:00', 'L', 1.25),
    (514, 1011, 5,   25.00, '2024-11-11 16:00:00', 'W', 1.00),
    (515, 1012, 4,  150.00, '2024-12-25 10:00:00', 'L', 1.00);

INSERT INTO bet_payout (Bet_ID, Payout_amount, Payout_timestamp) VALUES
    (502, 100.00, '2024-01-15 10:05:00'),
    (506, 200.00, '2024-04-10 09:05:00'),
    (507,  40.00, '2024-05-05 18:35:00'),
    (508,  40.00, '2024-05-05 18:35:00'),
    (511, 400.00, '2024-08-12 15:05:00'),
    (514,  50.00, '2024-11-11 16:05:00');
