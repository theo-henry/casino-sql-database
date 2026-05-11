-- =====================================================================
-- 01_schema.sql
-- Online Casino MySQL Schema (DDL)
-- Target: MySQL 8.0+
-- Run order: 1st (before 02_seed_data.sql)
--
-- Conventions:
--   * Engine: InnoDB (transactional, FK-aware).
--   * Charset / collation: utf8mb4 / utf8mb4_0900_ai_ci.
--   * Surrogate PKs use AUTO_INCREMENT; explicit IDs in seed data still
--     work and advance the counter as expected under InnoDB.
--   * Monetary columns use DECIMAL — never floats.
--   * Event timestamps use DATETIME (no silent timezone conversion,
--     no 2038 limit) rather than TIMESTAMP.
--   * CHECK constraints encode domain invariants (positive money,
--     coherent date windows, valid bet ranges).
-- =====================================================================

SET NAMES utf8mb4;
SET sql_mode = 'STRICT_ALL_TABLES,NO_ENGINE_SUBSTITUTION,ERROR_FOR_DIVISION_BY_ZERO';

-- Tables are dropped in reverse dependency order for idempotent reloads.
DROP TABLE IF EXISTS bet_payout;
DROP TABLE IF EXISTS bet;
DROP TABLE IF EXISTS ticket;
DROP TABLE IF EXISTS cc_payment_card;
DROP TABLE IF EXISTS cc_payment;
DROP TABLE IF EXISTS game_round;
DROP TABLE IF EXISTS game;
DROP TABLE IF EXISTS kyc_document;
DROP TABLE IF EXISTS registered_user;
DROP TABLE IF EXISTS user_address;
DROP TABLE IF EXISTS zip_code;
DROP TABLE IF EXISTS ticket_type;
DROP TABLE IF EXISTS game_type;
DROP TABLE IF EXISTS bet_outcome_type;
DROP TABLE IF EXISTS cc_payment_state;
DROP TABLE IF EXISTS cc_payment_type;
DROP TABLE IF EXISTS currency;
DROP TABLE IF EXISTS address_type;
DROP TABLE IF EXISTS kyc_verification_status;
DROP TABLE IF EXISTS kyc_document_type;
DROP TABLE IF EXISTS user_gender;
DROP TABLE IF EXISTS user_status;

-- =====================================================================
-- Reference / lookup tables
-- =====================================================================

CREATE TABLE user_status (
    Status_code CHAR(1)     NOT NULL,
    Description VARCHAR(40) NOT NULL,
    PRIMARY KEY (Status_code)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
  COMMENT = 'Lifecycle status for a registered player (Active, Banned, etc.).';

CREATE TABLE user_gender (
    Gender_code CHAR(1)     NOT NULL,
    Description VARCHAR(40) NOT NULL,
    PRIMARY KEY (Gender_code)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE kyc_document_type (
    Doc_type_code CHAR(3)     NOT NULL,
    Description   VARCHAR(40) NOT NULL,
    PRIMARY KEY (Doc_type_code)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
  COMMENT = 'Accepted KYC document categories (Passport, DL, ID, ...).';

CREATE TABLE kyc_verification_status (
    Status_code CHAR(1)     NOT NULL,
    Description VARCHAR(40) NOT NULL,
    PRIMARY KEY (Status_code)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE address_type (
    Type_ID     INT         NOT NULL,
    Description VARCHAR(40) NOT NULL,
    PRIMARY KEY (Type_ID)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE currency (
    Currency_ID   CHAR(3)     NOT NULL COMMENT 'ISO 4217 alpha-3 code.',
    Currency_Code SMALLINT    NOT NULL COMMENT 'ISO 4217 numeric code.',
    Description   VARCHAR(40) NOT NULL,
    PRIMARY KEY (Currency_ID),
    UNIQUE KEY uq_currency_numeric (Currency_Code)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE cc_payment_type (
    CCType      CHAR(2)     NOT NULL,
    Description VARCHAR(40) NOT NULL,
    PRIMARY KEY (CCType)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE cc_payment_state (
    CCState     CHAR(1)     NOT NULL,
    Description VARCHAR(40) NOT NULL,
    PRIMARY KEY (CCState)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE bet_outcome_type (
    Outcome_code CHAR(1)     NOT NULL,
    Description  VARCHAR(40) NOT NULL,
    PRIMARY KEY (Outcome_code)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE game_type (
    Game_type_code CHAR(3)     NOT NULL,
    Description    VARCHAR(40) NOT NULL,
    PRIMARY KEY (Game_type_code)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE ticket_type (
    TType_ID    INT         NOT NULL,
    Type_Name   VARCHAR(40) NOT NULL,
    Description VARCHAR(40) NOT NULL,
    PRIMARY KEY (TType_ID),
    UNIQUE KEY uq_ticket_type_name (Type_Name)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
  COMMENT = 'Wallet event types (Deposit, Withdrawal).';

-- =====================================================================
-- Location
-- =====================================================================

CREATE TABLE zip_code (
    ZIP_code INT         NOT NULL,
    Country  VARCHAR(20) NOT NULL,
    City     VARCHAR(20) NOT NULL,
    State    VARCHAR(20) NOT NULL,
    PRIMARY KEY (ZIP_code, Country)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
  COMMENT = 'Postal-code source of truth for City/State/Country (3NF).';

CREATE TABLE user_address (
    Address_ID     BIGINT      NOT NULL AUTO_INCREMENT,
    Type_ID        INT         NOT NULL,
    Address_Number SMALLINT    NOT NULL,
    ZIP_code       INT         NOT NULL,
    Country        VARCHAR(20) NOT NULL,
    PRIMARY KEY (Address_ID),
    KEY idx_user_address_zip (ZIP_code, Country),
    CONSTRAINT fk_user_address_type
        FOREIGN KEY (Type_ID) REFERENCES address_type (Type_ID),
    CONSTRAINT fk_user_address_zip
        FOREIGN KEY (ZIP_code, Country) REFERENCES zip_code (ZIP_code, Country),
    CONSTRAINT chk_user_address_number CHECK (Address_Number > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- =====================================================================
-- Player & KYC
-- =====================================================================

CREATE TABLE registered_user (
    User_ID           INT           NOT NULL AUTO_INCREMENT,
    Status_code       CHAR(1)       NOT NULL,
    Username          VARCHAR(64)   NOT NULL,
    First_name        VARCHAR(64)   NOT NULL,
    Last_name         VARCHAR(64)   NOT NULL,
    Second_surname    VARCHAR(64)   NULL,
    Email             VARCHAR(64)   NOT NULL,
    Phone_number      VARCHAR(20)   NULL COMMENT 'E.164-style string. Numeric storage drops leading zeros.',
    Address_ID        BIGINT        NULL,
    Passkey           VARCHAR(64)   NOT NULL COMMENT 'Hash digest; never the plain credential.',
    Date_of_birth     DATE          NOT NULL,
    Gender_code       CHAR(1)       NOT NULL,
    Registration_date DATETIME      NOT NULL,
    Currency_ID       CHAR(3)       NOT NULL,
    Account_balance   DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (User_ID),
    UNIQUE KEY uq_registered_user_username (Username),
    UNIQUE KEY uq_registered_user_email    (Email),
    KEY idx_registered_user_address  (Address_ID),
    KEY idx_registered_user_currency (Currency_ID),
    CONSTRAINT fk_registered_user_status
        FOREIGN KEY (Status_code) REFERENCES user_status (Status_code),
    CONSTRAINT fk_registered_user_gender
        FOREIGN KEY (Gender_code) REFERENCES user_gender (Gender_code),
    CONSTRAINT fk_registered_user_address
        FOREIGN KEY (Address_ID) REFERENCES user_address (Address_ID),
    CONSTRAINT fk_registered_user_currency
        FOREIGN KEY (Currency_ID) REFERENCES currency (Currency_ID),
    CONSTRAINT chk_registered_user_balance CHECK (Account_balance >= 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
  COMMENT = 'Central player entity. Soft profile data only — financial state lives elsewhere.';

CREATE TABLE kyc_document (
    KYC_doc_ID          BIGINT       NOT NULL AUTO_INCREMENT,
    User_ID             INT          NOT NULL,
    Doc_type_code       CHAR(3)      NOT NULL,
    Document_number     VARCHAR(100) NOT NULL,
    Issuing_country     CHAR(2)      NULL,
    Issue_date          DATE         NULL,
    Expiry_date         DATE         NULL,
    Status_code         CHAR(1)      NOT NULL DEFAULT 'P',
    Submitted_timestamp DATETIME     NOT NULL,
    Verified_timestamp  DATETIME     NULL,
    Last_updated        DATETIME     NULL,
    PRIMARY KEY (KYC_doc_ID),
    KEY idx_kyc_document_user_status (User_ID, Status_code),
    KEY idx_kyc_document_expiry (Expiry_date),
    CONSTRAINT fk_kyc_document_user
        FOREIGN KEY (User_ID) REFERENCES registered_user (User_ID),
    CONSTRAINT fk_kyc_document_type
        FOREIGN KEY (Doc_type_code) REFERENCES kyc_document_type (Doc_type_code),
    CONSTRAINT fk_kyc_document_status
        FOREIGN KEY (Status_code) REFERENCES kyc_verification_status (Status_code),
    CONSTRAINT chk_kyc_dates CHECK (Issue_date IS NULL OR Expiry_date IS NULL OR Issue_date <= Expiry_date),
    CONSTRAINT chk_kyc_verified_after_submit
        CHECK (Verified_timestamp IS NULL OR Verified_timestamp >= Submitted_timestamp)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
  COMMENT = 'Identity document audit trail. One row per submitted document.';

-- =====================================================================
-- Game catalogue & rounds
-- =====================================================================

CREATE TABLE game (
    Game_ID        INT           NOT NULL AUTO_INCREMENT,
    Game_name      VARCHAR(100)  NOT NULL,
    Game_type_code CHAR(3)       NOT NULL,
    Min_bet_amount DECIMAL(12,2) NOT NULL,
    Max_bet_amount DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (Game_ID),
    UNIQUE KEY uq_game_name (Game_name),
    KEY idx_game_type (Game_type_code),
    CONSTRAINT fk_game_type
        FOREIGN KEY (Game_type_code) REFERENCES game_type (Game_type_code),
    CONSTRAINT chk_game_min_positive CHECK (Min_bet_amount > 0),
    CONSTRAINT chk_game_range        CHECK (Min_bet_amount <= Max_bet_amount)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE game_round (
    Round_ID                     BIGINT   NOT NULL AUTO_INCREMENT,
    Game_ID                      INT      NOT NULL,
    Start_time                   DATETIME NOT NULL,
    End_time                     DATETIME NOT NULL,
    Random_number_generator_seed INT      NOT NULL,
    PRIMARY KEY (Round_ID),
    KEY idx_game_round_game_start (Game_ID, Start_time),
    CONSTRAINT fk_game_round_game
        FOREIGN KEY (Game_ID) REFERENCES game (Game_ID),
    CONSTRAINT chk_game_round_window CHECK (End_time >= Start_time)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
  COMMENT = 'A single deal/spin/hand. RNG seed is preserved for fairness audits.';

-- =====================================================================
-- Payments (precede ticket because tickets reference cc_payment)
-- =====================================================================

CREATE TABLE cc_payment (
    CCPayment_ID     BIGINT        NOT NULL AUTO_INCREMENT,
    CCPaytran_ID     BIGINT        NOT NULL,
    User_ID          INT           NOT NULL,
    Currency_ID      CHAR(3)       NOT NULL,
    Expected_amount  DECIMAL(20,5) NOT NULL,
    Approving_amount DECIMAL(20,5) NULL,
    Approved_amount  DECIMAL(20,5) NULL,
    CCPayment_state  CHAR(1)       NOT NULL,
    Timecreated      DATETIME      NOT NULL,
    Timeupdated      DATETIME      NULL,
    Timeexpired      DATETIME      NULL,
    PRIMARY KEY (CCPayment_ID),
    KEY idx_cc_payment_user_time (User_ID, Timecreated),
    KEY idx_cc_payment_state     (CCPayment_state),
    CONSTRAINT fk_cc_payment_currency
        FOREIGN KEY (Currency_ID)     REFERENCES currency (Currency_ID),
    CONSTRAINT fk_cc_payment_state
        FOREIGN KEY (CCPayment_state) REFERENCES cc_payment_state (CCState),
    CONSTRAINT fk_cc_payment_user
        FOREIGN KEY (User_ID)         REFERENCES registered_user (User_ID),
    CONSTRAINT chk_cc_payment_amount CHECK (Expected_amount > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE cc_payment_card (
    CCPayment_ID BIGINT      NOT NULL,
    Payment_Type CHAR(2)     NOT NULL,
    Is_encrypt   CHAR(1)     NOT NULL,
    Card_number  VARCHAR(64) NOT NULL COMMENT 'Tokenised / masked PAN — never the raw number.',
    Bankname     VARCHAR(64) NOT NULL,
    CCExpdate    CHAR(4)     NOT NULL COMMENT 'MMYY.',
    PRIMARY KEY (CCPayment_ID),
    CONSTRAINT fk_cc_payment_card_payment
        FOREIGN KEY (CCPayment_ID) REFERENCES cc_payment (CCPayment_ID),
    CONSTRAINT fk_cc_payment_card_type
        FOREIGN KEY (Payment_Type) REFERENCES cc_payment_type (CCType),
    CONSTRAINT chk_cc_payment_card_encrypt CHECK (Is_encrypt IN ('Y', 'N'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
  COMMENT = 'Card-level details, isolated from cc_payment for security boundary.';

-- =====================================================================
-- Wallet ledger
-- =====================================================================

CREATE TABLE ticket (
    Ticket_ID        BIGINT        NOT NULL AUTO_INCREMENT,
    User_ID          INT           NOT NULL,
    Currency_ID      CHAR(3)       NOT NULL,
    Ticket_timestamp DATETIME      NOT NULL,
    TType_ID         INT           NOT NULL,
    Payment_ID       BIGINT        NULL,
    Reference_ID     BIGINT        NOT NULL,
    Amount           DECIMAL(12,2) NOT NULL,
    exchange_rate    DECIMAL(12,6) NOT NULL DEFAULT 1.000000,
    PRIMARY KEY (Ticket_ID),
    KEY idx_ticket_user_time (User_ID, Ticket_timestamp),
    KEY idx_ticket_type      (TType_ID),
    KEY idx_ticket_payment   (Payment_ID),
    CONSTRAINT fk_ticket_user
        FOREIGN KEY (User_ID)     REFERENCES registered_user (User_ID),
    CONSTRAINT fk_ticket_currency
        FOREIGN KEY (Currency_ID) REFERENCES currency (Currency_ID),
    CONSTRAINT fk_ticket_type
        FOREIGN KEY (TType_ID)    REFERENCES ticket_type (TType_ID),
    CONSTRAINT fk_ticket_payment
        FOREIGN KEY (Payment_ID)  REFERENCES cc_payment (CCPayment_ID),
    CONSTRAINT chk_ticket_amount        CHECK (Amount > 0),
    CONSTRAINT chk_ticket_exchange_rate CHECK (exchange_rate > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
  COMMENT = 'Wallet ledger. One row per deposit / withdrawal event.';

-- =====================================================================
-- Bets & payouts
-- =====================================================================

CREATE TABLE bet (
    Bet_ID                  BIGINT        NOT NULL AUTO_INCREMENT,
    Round_ID                BIGINT        NOT NULL,
    User_ID                 INT           NOT NULL,
    Bet_amount              DECIMAL(12,2) NOT NULL,
    Bet_time                DATETIME      NOT NULL,
    Outcome_code            CHAR(1)       NOT NULL,
    exchange_rate_to_system DECIMAL(12,6) NOT NULL DEFAULT 1.000000,
    PRIMARY KEY (Bet_ID),
    KEY idx_bet_round         (Round_ID),
    KEY idx_bet_user_time     (User_ID, Bet_time),
    KEY idx_bet_time          (Bet_time),
    KEY idx_bet_outcome       (Outcome_code),
    CONSTRAINT fk_bet_round
        FOREIGN KEY (Round_ID)     REFERENCES game_round (Round_ID),
    CONSTRAINT fk_bet_user
        FOREIGN KEY (User_ID)      REFERENCES registered_user (User_ID),
    CONSTRAINT fk_bet_outcome
        FOREIGN KEY (Outcome_code) REFERENCES bet_outcome_type (Outcome_code),
    CONSTRAINT chk_bet_amount        CHECK (Bet_amount > 0),
    CONSTRAINT chk_bet_exchange_rate CHECK (exchange_rate_to_system > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
  COMMENT = 'Stake placed on a single round. exchange_rate_to_system normalises to the accounting currency.';

CREATE TABLE bet_payout (
    Bet_ID           BIGINT        NOT NULL,
    Payout_amount    DECIMAL(12,2) NOT NULL,
    Payout_timestamp DATETIME      NOT NULL,
    PRIMARY KEY (Bet_ID),
    KEY idx_bet_payout_time (Payout_timestamp),
    CONSTRAINT fk_bet_payout_bet
        FOREIGN KEY (Bet_ID) REFERENCES bet (Bet_ID),
    CONSTRAINT chk_bet_payout_amount CHECK (Payout_amount > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
  COMMENT = 'Payout for a winning bet. Absence of a row = loss (1:1 with bet).';
