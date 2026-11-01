-- Auth Service schema (PostgreSQL). Proposed starting point: adapt it in TASK-03.
CREATE TABLE users (
    id            BIGSERIAL    PRIMARY KEY,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,          -- PBKDF2 hash (salt + iterations encoded by the encoder)
    full_name     VARCHAR(255) NOT NULL,
    role          VARCHAR(20)  NOT NULL DEFAULT 'CUSTOMER', -- CUSTOMER | ADMIN
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT now()
);
