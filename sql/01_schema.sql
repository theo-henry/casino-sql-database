-- =====================================================================
-- 01_schema.sql
-- Online Casino MySQL Schema (DDL)
-- Run order: 1st (before 02_seed_data.sql)
-- Target: MySQL 8.0+
-- =====================================================================

-- ---------------------------------------------------------------------
-- Lookup / reference tables
-- ---------------------------------------------------------------------

CREATE TABLE user_status (
    Status_code  CHAR(1)     NOT NULL,
    Description  VARCHAR(40) NOT NULL,
    PRIMARY KEY (Status_code)
);

CREATE TABLE user_gender (
    Gender_code  CHAR(1)     NOT NULL,
    Description  VARCHAR(40) NOT NULL,
    PRIMARY KEY (Gender_code)
);

CREATE TABLE kyc_document_type (
    Doc_type_code  CHAR(3)     NOT NULL,
    Description    VARCHAR(40) NOT NULL,
    PRIMARY KEY (Doc_type_code)
);

CREATE TABLE kyc_verification_status (
    Status_code  CHAR(1)     NOT NULL,
    Description  VARCHAR(40) NOT NULL,
    PRIMARY KEY (Status_code)
);

CREATE TABLE address_type (
    Type_ID      INT         NOT NULL,
    Description  VARCHAR(40) NOT NULL,
    PRIMARY KEY (Type_ID)
);

CREATE TABLE currency (
    Currency_ID    CHAR(3)     NOT NULL,
    Currency_Code  SMALLINT(6) NOT NULL,
    Description    VARCHAR(40) NOT NULL,
    PRIMARY KEY (Currency_ID)
);

CREATE TABLE cc_payment_type (
    CCType       CHAR(2)     NOT NULL,
    Description  VARCHAR(40) NOT NULL,
    PRIMARY KEY (CCType)
);

CREATE TABLE cc_payment_state (
    CCState      CHAR(1)     NOT NULL,
    Description  VARCHAR(40) NOT NULL,
    PRIMARY KEY (CCState)
);

CREATE TABLE bet_outcome_type (
    Outcome_code  CHAR(1)     NOT NULL,
    Description   VARCHAR(40) NOT NULL,
    PRIMARY KEY (Outcome_code)
);

CREATE TABLE game_type (
    Game_type_code  CHAR(3)     NOT NULL,
    Description     VARCHAR(40) NOT NULL,
    PRIMARY KEY (Game_type_code)
);

CREATE TABLE ticket_type (
    TType_ID     INT         NOT NULL,
    Type_Name    VARCHAR(40) NOT NULL,
    Description  VARCHAR(40) NOT NULL,
    PRIMARY KEY (TType_ID)
);

-- ---------------------------------------------------------------------
-- Location
-- ---------------------------------------------------------------------

CREATE TABLE zip_code (
    ZIP_code  INT         NOT NULL,
    Country   VARCHAR(20) NOT NULL,
    City      VARCHAR(20) NOT NULL,
    State     VARCHAR(20) NOT NULL,
    PRIMARY KEY (ZIP_code, Country)
);

CREATE TABLE user_address (
    Address_ID      BIGINT(20)  NOT NULL,
    Type_ID         INT         NOT NULL,
    Address_Number  SMALLINT(6) NOT NULL,
    ZIP_code        INT         NOT NULL,
    Country         VARCHAR(20) NOT NULL,
    PRIMARY KEY (Address_ID),
    CONSTRAINT fk_user_address_type
        FOREIGN KEY (Type_ID) REFERENCES address_type (Type_ID),
    CONSTRAINT fk_user_address_zip
        FOREIGN KEY (ZIP_code, Country) REFERENCES zip_code (ZIP_code, Country)
);

-- ---------------------------------------------------------------------
-- Player & KYC
-- ---------------------------------------------------------------------

CREATE TABLE registered_user (
    User_ID            INT          NOT NULL,
    Status_code        CHAR(1)      NOT NULL,
    Username           VARCHAR(64)  NOT NULL,
    First_name         VARCHAR(64)  NOT NULL,
    Last_name          VARCHAR(64)  NOT NULL,
    Second_surname     VARCHAR(64),
    Email              VARCHAR(64)  NOT NULL,
    Phone_number       BIGINT(20),
    Address_ID         BIGINT(20),
    Passkey            VARCHAR(64)  NOT NULL,
    Date_of_birth      DATE         NOT NULL,
    Gender_code        CHAR(1)      NOT NULL,
    Registration_date  TIMESTAMP    NOT NULL,
    Currency_ID        CHAR(3)      NOT NULL,
    Account_balance    DECIMAL(12,2) DEFAULT 0.00,
    PRIMARY KEY (User_ID),
    UNIQUE KEY uq_registered_user_username (Username),
    UNIQUE KEY uq_registered_user_email (Email),
    CONSTRAINT fk_registered_user_status
        FOREIGN KEY (Status_code)  REFERENCES user_status (Status_code),
    CONSTRAINT fk_registered_user_gender
        FOREIGN KEY (Gender_code)  REFERENCES user_gender (Gender_code),
    CONSTRAINT fk_registered_user_address
        FOREIGN KEY (Address_ID)   REFERENCES user_address (Address_ID),
    CONSTRAINT fk_registered_user_currency
        FOREIGN KEY (Currency_ID)  REFERENCES currency (Currency_ID)
);

CREATE TABLE kyc_document (
    KYC_doc_ID          BIGINT(20)   NOT NULL,
    User_ID             INT          NOT NULL,
    Doc_type_code       CHAR(3)      NOT NULL,
    Document_number     VARCHAR(100) NOT NULL,
    Issuing_country     CHAR(2),
    Issue_date          DATE,
    Expiry_date         DATE,
    Status_code         CHAR(1)      NOT NULL DEFAULT 'P',
    Submitted_timestamp TIMESTAMP    NOT NULL,
    Verified_timestamp  TIMESTAMP    NULL,
    Last_updated        TIMESTAMP    NULL,
    PRIMARY KEY (KYC_doc_ID),
    CONSTRAINT fk_kyc_document_user
        FOREIGN KEY (User_ID)        REFERENCES registered_user (User_ID),
    CONSTRAINT fk_kyc_document_type
        FOREIGN KEY (Doc_type_code)  REFERENCES kyc_document_type (Doc_type_code),
    CONSTRAINT fk_kyc_document_status
        FOREIGN KEY (Status_code)    REFERENCES kyc_verification_status (Status_code)
);

-- ---------------------------------------------------------------------
-- Games
-- ---------------------------------------------------------------------

CREATE TABLE game (
    Game_ID         INT           NOT NULL,
    Game_name       VARCHAR(100)  NOT NULL,
    Game_type_code  CHAR(3)       NOT NULL,
    Min_bet_amount  DECIMAL(12,2) NOT NULL,
    Max_bet_amount  DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (Game_ID),
    CONSTRAINT fk_game_type
        FOREIGN KEY (Game_type_code) REFERENCES game_type (Game_type_code)
);

CREATE TABLE game_round (
    Round_ID                     BIGINT(20) NOT NULL,
    Game_ID                      INT        NOT NULL,
    Start_time                   TIMESTAMP  NOT NULL,
    End_time                     TIMESTAMP  NOT NULL,
    Random_number_generator_seed INT        NOT NULL,
    PRIMARY KEY (Round_ID),
    CONSTRAINT fk_game_round_game
        FOREIGN KEY (Game_ID) REFERENCES game (Game_ID)
);

-- ---------------------------------------------------------------------
-- Payments (must exist before ticket because ticket FKs cc_payment)
-- ---------------------------------------------------------------------

CREATE TABLE cc_payment (
    CCPayment_ID     BIGINT(20)    NOT NULL,
    CCPaytran_ID     BIGINT(20)    NOT NULL,
    User_ID          INT(11)       NOT NULL,
    Currency_ID      CHAR(3)       NOT NULL,
    Expected_amount  DECIMAL(20,5) NOT NULL,
    Approving_amount DECIMAL(20,5),
    Approved_amount  DECIMAL(20,5),
    CCPayment_state  CHAR(1)       NOT NULL,
    Timecreated      TIMESTAMP     NOT NULL,
    Timeupdated      TIMESTAMP     NULL,
    Timeexpired      TIMESTAMP     NULL,
    PRIMARY KEY (CCPayment_ID),
    CONSTRAINT fk_cc_payment_currency
        FOREIGN KEY (Currency_ID)     REFERENCES currency (Currency_ID),
    CONSTRAINT fk_cc_payment_state
        FOREIGN KEY (CCPayment_state) REFERENCES cc_payment_state (CCState),
    CONSTRAINT fk_cc_payment_user
        FOREIGN KEY (User_ID)         REFERENCES registered_user (User_ID)
);

CREATE TABLE cc_payment_card (
    CCPayment_ID  BIGINT(20)  NOT NULL,
    Payment_Type  CHAR(2)     NOT NULL,
    Is_encrypt    CHAR(1)     NOT NULL,
    Card_number   VARCHAR(64) NOT NULL,
    Bankname      VARCHAR(64) NOT NULL,
    CCExpdate     CHAR(6)     NOT NULL,
    PRIMARY KEY (CCPayment_ID),
    CONSTRAINT fk_cc_payment_card_payment
        FOREIGN KEY (CCPayment_ID) REFERENCES cc_payment (CCPayment_ID),
    CONSTRAINT fk_cc_payment_card_type
        FOREIGN KEY (Payment_Type) REFERENCES cc_payment_type (CCType)
);

-- ---------------------------------------------------------------------
-- Wallet ledger
-- ---------------------------------------------------------------------

CREATE TABLE ticket (
    Ticket_ID         BIGINT(20)    NOT NULL,
    User_ID           INT           NOT NULL,
    Currency_ID       CHAR(3)       NOT NULL,
    Ticket_timestamp  TIMESTAMP     NOT NULL,
    TType_ID          INT           NOT NULL,
    Payment_ID        BIGINT(20)    NULL,
    Reference_ID      BIGINT(20)    NOT NULL,
    Amount            DECIMAL(12,2) NOT NULL,
    exchange_rate     DECIMAL(12,6) DEFAULT 1.000000,
    PRIMARY KEY (Ticket_ID),
    CONSTRAINT fk_ticket_user
        FOREIGN KEY (User_ID)     REFERENCES registered_user (User_ID),
    CONSTRAINT fk_ticket_currency
        FOREIGN KEY (Currency_ID) REFERENCES currency (Currency_ID),
    CONSTRAINT fk_ticket_type
        FOREIGN KEY (TType_ID)    REFERENCES ticket_type (TType_ID),
    CONSTRAINT fk_ticket_payment
        FOREIGN KEY (Payment_ID)  REFERENCES cc_payment (CCPayment_ID)
);

-- ---------------------------------------------------------------------
-- Bets & payouts
-- ---------------------------------------------------------------------

CREATE TABLE bet (
    Bet_ID                  BIGINT(20)    NOT NULL,
    Round_ID                BIGINT(20)    NOT NULL,
    User_ID                 INT           NOT NULL,
    Bet_amount              DECIMAL(12,2) NOT NULL,
    Bet_time                TIMESTAMP     NOT NULL,
    Outcome_code            CHAR(1)       NOT NULL,
    exchange_rate_to_system DECIMAL(12,6) DEFAULT 1.000000,
    PRIMARY KEY (Bet_ID),
    CONSTRAINT fk_bet_round
        FOREIGN KEY (Round_ID)     REFERENCES game_round (Round_ID),
    CONSTRAINT fk_bet_user
        FOREIGN KEY (User_ID)      REFERENCES registered_user (User_ID),
    CONSTRAINT fk_bet_outcome
        FOREIGN KEY (Outcome_code) REFERENCES bet_outcome_type (Outcome_code)
);

CREATE TABLE bet_payout (
    Bet_ID            BIGINT(20)    NOT NULL,
    Payout_amount     DECIMAL(12,2) NOT NULL,
    Payout_timestamp  TIMESTAMP     NOT NULL,
    PRIMARY KEY (Bet_ID),
    CONSTRAINT fk_bet_payout_bet
        FOREIGN KEY (Bet_ID) REFERENCES bet (Bet_ID)
);
