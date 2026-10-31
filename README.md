# Online Bookstore

## 1. Project Overview

Build an **online bookstore** using a **microservices architecture** and a **JavaFX shopping client**.

Customers can browse and search for books, add items to a cart, and place orders. An order is confirmed **only if the Inventory service successfully reserves the stock and the simulated payment succeeds**.

Staff use an admin interface within the same JavaFX client to manage books, update inventory, and monitor orders.

**Core concepts:** independent services and databases, an API gateway, synchronous inter-service communication, automated testing, and containerized deployment.

## 2. Microservices Architecture

| Service | Responsibilities | Database |
| --- | --- | --- |
| **API Gateway** | Request routing, token validation, and correlation IDs | — |
| **Auth Service** | User registration, login, PBKDF2 password hashing, and token issuing | PostgreSQL |
| **Catalog Service** | Books, authors, categories, and catalogue search | PostgreSQL |
| **Inventory Service** | Stock levels and stock reservations | MySQL |
| **Order Service** | Shopping carts, order management, and calls to Inventory and a simulated Payment endpoint | PostgreSQL |

## 3. Functional Requirements

### 3.1 Customer Features (JavaFX)

- Browse a catalogue grid with book covers.
- Search for books and apply filters.
- Add books to a shopping cart.
- Check out and place orders.
- View order history.

### 3.2 Admin Features (JavaFX)

- Add and edit book details.
- Update stock levels.
- View all orders and their statuses.

### 3.3 Order Processing

1. The customer submits an order.
2. The Order service requests a stock reservation from Inventory.
3. If the reservation succeeds, the Order service requests a simulated payment.
4. **If payment succeeds:** confirm the order.
5. **If payment fails:** release the stock reservation and do not confirm the order.
6. **If stock is unavailable:** reject the order without proceeding to payment.

The JavaFX client must display clear error messages when a service is unavailable.

## 4. Test-Driven Development (TDD)

### 4.1 Unit Tests

Write tests for order rules **before implementing the corresponding logic**, including:

- Empty shopping cart.
- Out-of-stock items.
- Refused payments.

### 4.2 Contract Tests

- Express the Order service's expectations of the Inventory API as **WireMock stubs**.
- Verify those expectations against the real Inventory service.

### 4.3 Repository Tests

- Use **Testcontainers** to test persistence against each service's database technology.

### 4.4 End-to-End Tests

Run the following scenario on the composed stack:

1. Register a user.
2. Purchase two books.
3. Verify that stock levels decreased accordingly.

## 5. CI/CD and Docker

**CI/CD platform:** GitHub Actions  
**Trigger:** `on: push`

### 5.1 Continuous Integration

On every push:

1. Detect which services changed using **path filters**.
2. Build and test only the changed services through service-specific workflows.
3. Start the entire stack in the GitHub Actions runner:

   ```bash
   docker compose up --wait
   ```

4. Run end-to-end tests against the **API Gateway**.

### 5.2 Deployment (`main` Branch)

When changes reach `main`:

1. Build and push service images to **GitHub Container Registry (GHCR)**.
2. Connect to the demo machine using a **GitHub Actions SSH action**.
3. Pull and restart services:

   ```bash
   docker compose pull && docker compose up -d
   ```

4. Check each service's `/health` endpoint.
5. If any health check fails, **roll back to the previous image tag**.

### 5.3 Versioned Images

On version tags, build and push each service's Docker image to **GHCR**, tagged with the corresponding version.

### 5.4 GitHub Releases

Attach the following assets to each GitHub Release:

- JavaFX client installers.
- `docker-compose.yml` for running the full system.
