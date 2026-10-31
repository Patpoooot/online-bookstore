-- Catalog Service schema (PostgreSQL). Proposed starting point: adapt it in TASK-04.
CREATE TABLE categories (
    id   BIGSERIAL    PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE authors (
    id   BIGSERIAL    PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE books (
    id               BIGSERIAL     PRIMARY KEY,
    isbn             VARCHAR(20)   NOT NULL UNIQUE,
    title            VARCHAR(255)  NOT NULL,
    description      TEXT,
    price            NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    cover_url        VARCHAR(500),
    publication_year INTEGER,
    category_id      BIGINT        REFERENCES categories (id)
);

CREATE TABLE book_authors (
    book_id   BIGINT NOT NULL REFERENCES books (id) ON DELETE CASCADE,
    author_id BIGINT NOT NULL REFERENCES authors (id),
    PRIMARY KEY (book_id, author_id)
);

CREATE INDEX idx_books_title ON books (lower(title));
CREATE INDEX idx_books_category ON books (category_id);
