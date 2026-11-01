-- Inventory Service schema (MySQL 8). Proposed starting point: adapt it in TASK-05.
-- book_id refers to the Catalog Service book id (no cross-database foreign key).
CREATE TABLE stock_items (
    book_id            BIGINT NOT NULL PRIMARY KEY,
    quantity_available INT    NOT NULL CHECK (quantity_available >= 0),
    version            BIGINT NOT NULL DEFAULT 0          -- optimistic locking (@Version)
) ENGINE = InnoDB;

CREATE TABLE reservations (
    id         BIGINT      NOT NULL AUTO_INCREMENT PRIMARY KEY,
    order_id   BIGINT      NOT NULL UNIQUE,                -- makes "reserve" idempotent per order
    status     VARCHAR(20) NOT NULL,                       -- RESERVED | RELEASED | CONFIRMED
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

CREATE TABLE reservation_lines (
    id             BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    reservation_id BIGINT NOT NULL,
    book_id        BIGINT NOT NULL,
    quantity       INT    NOT NULL CHECK (quantity > 0),
    CONSTRAINT fk_line_reservation FOREIGN KEY (reservation_id) REFERENCES reservations (id) ON DELETE CASCADE
) ENGINE = InnoDB;
