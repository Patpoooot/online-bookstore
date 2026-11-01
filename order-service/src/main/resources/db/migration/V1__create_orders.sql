-- Order Service schema (PostgreSQL). Proposed starting point: adapt it in TASK-06.
-- user_id / book_id refer to other services' ids (no cross-database foreign keys).
CREATE TABLE carts (
    id      BIGSERIAL PRIMARY KEY,
    user_id BIGINT    NOT NULL UNIQUE
);

CREATE TABLE cart_items (
    id         BIGSERIAL     PRIMARY KEY,
    cart_id    BIGINT        NOT NULL REFERENCES carts (id) ON DELETE CASCADE,
    book_id    BIGINT        NOT NULL,
    title      VARCHAR(255)  NOT NULL,      -- snapshot for display
    unit_price NUMERIC(10,2) NOT NULL,      -- snapshot of the catalogue price
    quantity   INTEGER       NOT NULL CHECK (quantity > 0),
    UNIQUE (cart_id, book_id)
);

CREATE TABLE orders (
    id             BIGSERIAL     PRIMARY KEY,
    user_id        BIGINT        NOT NULL,
    status         VARCHAR(20)   NOT NULL,  -- PENDING | CONFIRMED | REJECTED | PAYMENT_FAILED
    total_amount   NUMERIC(10,2) NOT NULL,
    reservation_id BIGINT,
    failure_reason VARCHAR(255),
    created_at     TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE TABLE order_lines (
    id         BIGSERIAL     PRIMARY KEY,
    order_id   BIGINT        NOT NULL REFERENCES orders (id) ON DELETE CASCADE,
    book_id    BIGINT        NOT NULL,
    title      VARCHAR(255)  NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    quantity   INTEGER       NOT NULL CHECK (quantity > 0)
);

CREATE INDEX idx_orders_user ON orders (user_id);
