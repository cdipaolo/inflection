-- init.sql
--
-- Initializes SQLite database to hold
-- the Yelp Academic Dataset (specifically
-- Round 7 data).
DROP TABLE IF EXISTS business;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS review;

CREATE TABLE business (
    business_id    VARCHAR(25) PRIMARY KEY,
    name           TEXT DEFAULT "",
    type           VARCHAR(25) DEFAULT "",
    city           TEXT DEFAULT "",
    state          VARCHAR(2) DEFAULT "",
    longitude      DECIMAL(9,6) DEFAULT 0.0,
    latitude       DECIMAL(9,6) DEFAULT 0.0,
    stars          FLOAT DEFAULT 0.0,
    review_count   INTEGER DEFAULT 0,
    categories     TEXT DEFAULT "", -- json array
    attributes     TEXT DEFAULT "", -- json object
    checkin_info   TEXT DEFAULT ""  -- json object
);

CREATE TABLE users (
    user_id        VARCHAR(25) PRIMARY KEY,
    name           VARCHAR(25) DEFAULT "",
    review_count   INTEGER DEFAULT 0,
    average_stars  FLOAT DEFAULT 0
);

CREATE TABLE review (
    user_id     VARCHAR(25),
    business_id VARCHAR(25),
    stars       FLOAT DEFAULT 0,
    text        TEXT DEFAULT "",
    timestamp   VARCHAR(10) DEFAULT "0000-00-00",
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (business_id) REFERENCES business(business_id)
);
