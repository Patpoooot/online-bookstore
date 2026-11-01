# REST API (proposal)

Proposed endpoints, all reached **through the gateway** (`http://localhost:8080`) unless marked
*internal*. Finalise this table in TASK-02 and keep it up to date: it is the agreement between the
two team members (backend ↔ client). Errors always use the `ErrorResponse` JSON format
(`status`, `error`, `message`, `path`, `correlationId`, `timestamp`).

Auth column: **public** = no token, **user** = any valid token, **admin** = role `ADMIN`.

## Auth Service

| Method | Path | Auth | Description |
| --- | --- | --- | --- |
| POST | `/api/auth/register` | public | Create a customer account `{email, password, fullName}` → 201 |
| POST | `/api/auth/login` | public | `{email, password}` → `{token, expiresAt, userId, role}` |

## Catalog Service

| Method | Path | Auth | Description |
| --- | --- | --- | --- |
| GET | `/api/books?query=&categoryId=&authorId=&minPrice=&maxPrice=&page=&size=` | public | Paged search with filters |
| GET | `/api/books/{id}` | public | Book details (incl. `coverUrl`, authors, category) |
| GET | `/api/categories` | public | Categories (filter values) |
| GET | `/api/authors` | public | Authors (filter values) |
| POST | `/api/admin/books` | admin | Add a book |
| PUT | `/api/admin/books/{id}` | admin | Edit a book |

## Inventory Service

| Method | Path | Auth | Description |
| --- | --- | --- | --- |
| GET | `/api/inventory/stock?bookIds=1,2,3` | public | Available quantities |
| GET | `/api/inventory/stock/{bookId}` | public | Available quantity of one book (used by the E2E test) |
| PUT | `/api/admin/inventory/{bookId}` | admin | Set the stock level `{quantity}` (creates the record if absent) |
| POST | `/api/inventory/reservations` | *internal* | `{orderId, items:[{bookId, quantity}]}` → 201 `{reservationId, status:"RESERVED"}` or 409 `INSUFFICIENT_STOCK` (all-or-nothing) |
| POST | `/api/inventory/reservations/{id}/confirm` | *internal* | Make the reservation final |
| DELETE | `/api/inventory/reservations/{id}` | *internal* | Release: stock is given back |

The *internal* endpoints form the **Order → Inventory contract** (`contracts/inventory-api`).

## Order Service

| Method | Path | Auth | Description |
| --- | --- | --- | --- |
| GET | `/api/cart` | user | Current user's cart |
| POST | `/api/cart/items` | user | Add `{bookId, quantity}` (price/title snapshot taken from the Catalog request body or a Catalog call — decide in TASK-02) |
| PUT | `/api/cart/items/{bookId}` | user | Change quantity |
| DELETE | `/api/cart/items/{bookId}` | user | Remove an item |
| POST | `/api/orders` | user | Checkout the cart → order with status `CONFIRMED`, `REJECTED` or `PAYMENT_FAILED` |
| GET | `/api/orders` | user | Order history of the current user |
| GET | `/api/admin/orders?status=` | admin | All orders with their statuses |
| POST | `/internal/payments` | *internal* | Simulated payment `{orderId, amount}` → `{status: APPROVED or DECLINED}` |

## Error codes

| HTTP | `error` | When |
| --- | --- | --- |
| 400 | `VALIDATION_ERROR` | Invalid request body / parameters |
| 400 | `EMPTY_CART` | Checkout with an empty cart |
| 401 | `UNAUTHORIZED` | Missing / invalid / expired token (gateway) |
| 403 | `FORBIDDEN` | Non-admin calling `/api/admin/**` (gateway) |
| 404 | `NOT_FOUND` | Unknown resource |
| 409 | `EMAIL_ALREADY_USED` | Registration with an existing email |
| 409 | `INSUFFICIENT_STOCK` | Reservation impossible |
| 402 | `PAYMENT_REFUSED` | Simulated payment declined |
| 503 | `SERVICE_UNAVAILABLE` | A downstream service did not answer (gateway or Order Service) |
