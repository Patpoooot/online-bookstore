# TASKS — Online Bookstore development roadmap

> **Source of truth for requirements:** the professor's [`README.md`](README.md).
> **How it is built:** [`docs/architecture.md`](docs/architecture.md) · [`docs/api.md`](docs/api.md) · [`docs/development.md`](docs/development.md).
> Tick a box (`[x]`) when the item is done, and update the progress tracker below at the end of each day.

---

## 1. Project overview

**Goal.** Deliver an online bookstore built from independent microservices (API Gateway, Auth,
Catalog, Inventory, Order), each with its own database, used through a single **JavaFX client** with
customer and admin views. An order is **confirmed only if Inventory reserves the stock and the
simulated payment succeeds**. The project must be test-driven (unit, contract, repository and
end-to-end tests), containerised with Docker Compose, and built, deployed and released with GitHub Actions.

**Objectives (all mandatory, from the README)**

1. Five services with the responsibilities and databases of README §2, communicating synchronously via REST.
2. JavaFX customer features (browse grid with covers, search + filters, cart, checkout, order history) and admin features (add/edit books, update stock, view all orders and statuses).
3. The order workflow of README §3.3, including stock release on refused payment and clear client error messages when a service is unavailable.
4. Tests: TDD unit tests for order rules, WireMock contract tests verified against the real Inventory service, Testcontainers repository tests, end-to-end scenario on the composed stack.
5. CI/CD: path-filtered service builds, `docker compose up --wait` + E2E in CI, GHCR images, SSH deployment with `/health` checks and rollback, versioned images on tags, GitHub Releases with client installers and `docker-compose.yml`.

| | |
| --- | --- |
| **Start date** | Saturday, October 31, 2026 |
| **Final deadline** | Friday, November 20, 2026 |
| **Team** | Member A, Member B |
| **Expected workload** | ≈ 25 h per member per week (estimates include writing the tests) |
| **Buffer** | ≈ 15 % of each week is unplanned; Nov 19–20 are reserved for fixes and delivery |

### Main milestones

| # | Milestone | Deadline | Owner |
| --- | --- | --- | --- |
| M1 | Team ready, skeleton builds, API contract & business rules agreed | Nov 1 | Both |
| M2 | Persistence layer of every service (entities, repositories, Testcontainers tests) | Nov 4 | Both |
| M3 | Core functionality: login + gateway security, order rules implemented test-first, CI green | Nov 6 | Both |
| M4 | All service APIs implemented; Order → Inventory contract verified | Nov 10 | Both |
| M5 | All client features working end to end through the gateway | Nov 13 | Both |
| M6 | Automated E2E test in CI; deployment, rollback and release pipelines working | Nov 17 | Both |
| M7 | Stabilised, documented, `v1.0.0` released and submitted | **Nov 20** | Both |

### Team responsibilities

The split follows the **request flow**, so each member owns complete vertical slices and both can
work in parallel from day one. Interfaces between the two halves are fixed early (TASK-02, TASK-10).

| | **Member A — "entry & catalogue" side** | **Member B — "order processing" side** |
| --- | --- | --- |
| Services | Auth Service, API Gateway, Catalog Service | Inventory Service, Order Service (incl. simulated Payment), `bookstore-common` |
| Tests | Auth/Gateway/Catalog unit, web and repository tests | Order-rule TDD tests, contract tests (both sides), Inventory/Order repository tests, E2E test |
| Client (JavaFX) | App shell, API client, login/register, catalogue grid/search/filters, all admin views | Cart, checkout, order history, outcome/error messages for orders |
| DevOps | CI on GitHub, deployment to the demo machine with health checks and rollback | Release workflow: versioned images, jpackage installers, GitHub Release |
| **Shared** | API contract (TASK-02), contract stubs review (TASK-10), weekly reviews (TASK-13), integration checkpoint (TASK-23), bug fixing (TASK-28), documentation (TASK-29), final delivery (TASK-30) | same |

**Working agreement:** one branch per task (`feature/TASK-xx-name`); every pull request is reviewed by
the other member; `main` must stay green; short daily sync (10 min) to report progress and blockers;
whoever changes `docs/api.md` tells the other member.

### High-level progress tracker

| Week | Dates | Tasks | Done | Status |
| --- | --- | --- | --- | --- |
| Week 1 — Foundations | Oct 31 – Nov 6 | TASK-01 … TASK-13 | 0 / 13 | ⬜ Not started |
| Week 2 — Features & integration | Nov 7 – Nov 13 | TASK-14 … TASK-23 | 0 / 10 | ⬜ Not started |
| Week 3 — Testing, delivery | Nov 14 – Nov 20 | TASK-24 … TASK-30 | 0 / 7 | ⬜ Not started |
| **Total** | | **30 tasks** | **0 / 30** | |

| Milestone | M1 | M2 | M3 | M4 | M5 | M6 | M7 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Status | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |

Legend: ⬜ not started · 🟨 in progress · ✅ done · 🟥 late / blocked

### Planned effort per member

| | Week 1 | Week 2 | Week 3 | Total |
| --- | --- | --- | --- | --- |
| Member A | 28 h | 28 h | 21 h | ≈ 77 h |
| Member B | 25 h | 30 h | 21 h | ≈ 76 h |

---

## 2. Week 1 — October 31 – November 6: Architecture, configuration, database foundations, core functionality

### Milestone M1 — Team ready, contract agreed (deadline Nov 1)

- [ ] **TASK-01 — Kick-off, environment and repository setup**
  - **Owner:** Both · **Start:** Oct 31 · **Deadline:** Oct 31 · **Effort:** 2 h each · **Depends on:** —
  - [ ] Both read the README and `docs/architecture.md`; agree on the A/B split in this file.
  - [ ] Install JDK 21, Docker (Compose v2) and the IDE; import the Maven project.
  - [ ] Run `./mvnw verify` (unit + Testcontainers smoke tests) and `docker compose up --build --wait`; then `docker compose down -v`.
  - [ ] Protect `main` on GitHub (pull request + green CI required); create labels `week-1/2/3`.
  - [ ] Copy `.env.example` to `.env` locally.
  - **Done when:** both members have a green local build and the full stack starts on both machines.

- [ ] **TASK-02 — Finalise the API contract and business rules**
  - **Owner:** Both · **Start:** Oct 31 · **Deadline:** Nov 1 · **Effort:** 3 h each · **Depends on:** TASK-01
  - [ ] Review and complete every endpoint, request and response in `docs/api.md` (field names, types, status codes).
  - [ ] Fix the simulated payment rule (proposal: declined if amount > 500.00 or the payment token is `DECLINE`).
  - [ ] Decide how the cart gets title/price (client sends them vs. Order calls Catalog) — keep it simple.
  - [ ] Confirm order statuses (`PENDING`, `CONFIRMED`, `REJECTED`, `PAYMENT_FAILED`) and error codes.
  - [ ] Decide how the first admin account is created (proposal: seeded by an Auth Flyway migration).
  - **Done when:** `docs/api.md` is merged and both members agree that it is complete for every README feature.

### Milestone M2 — Persistence layer of every service (deadline Nov 4)

- [ ] **TASK-03 — Auth persistence**
  - **Owner:** Member A · **Start:** Nov 1 · **Deadline:** Nov 3 · **Effort:** 3 h · **Depends on:** TASK-02
  - [ ] Adjust `V1__create_users.sql` if needed; add `V2__seed_admin.sql` (PBKDF2 hash of a known demo password).
  - [ ] `User` entity + `Role` enum (`model`), `UserRepository` with `findByEmail` (`repository`).
  - [ ] `UserRepositoryIT` with Testcontainers PostgreSQL (save, find by email, unique email).
  - **Done when:** `./mvnw -pl auth-service -am verify` passes with the repository test.

- [ ] **TASK-04 — Catalog persistence and seed data**
  - **Owner:** Member A · **Start:** Nov 2 · **Deadline:** Nov 4 · **Effort:** 5 h · **Depends on:** TASK-02
  - [ ] `Book`, `Author`, `Category` entities with their relations; repositories.
  - [ ] Search query (title/author text + category + price range, paged) via JPQL or Specifications.
  - [ ] `V2__seed_catalog.sql`: ≥ 12 books with `cover_url`, ≥ 4 categories, authors. **Share the book ids with Member B** (needed by TASK-05).
  - [ ] `BookRepositoryIT` (Testcontainers PostgreSQL) covering the search filters.
  - **Done when:** the search returns the expected seed books for each filter in the repository test.

- [ ] **TASK-05 — Inventory persistence**
  - **Owner:** Member B · **Start:** Nov 1 · **Deadline:** Nov 3 · **Effort:** 4 h · **Depends on:** TASK-02 (book ids from TASK-04 for the seed only)
  - [ ] `StockItem` (with `@Version`), `Reservation`, `ReservationLine`, `ReservationStatus`; repositories.
  - [ ] `V2__seed_stock.sql` with stock for every seed book id.
  - [ ] `StockItemRepositoryIT` and `ReservationRepositoryIT` with Testcontainers **MySQL**.
  - **Done when:** `./mvnw -pl inventory-service -am verify` passes against MySQL.

- [ ] **TASK-06 — Order persistence**
  - **Owner:** Member B · **Start:** Nov 2 · **Deadline:** Nov 4 · **Effort:** 4 h · **Depends on:** TASK-02
  - [ ] `Cart`, `CartItem`, `Order`, `OrderLine`, `OrderStatus`; repositories (`findByUserId`, orders by user, by status).
  - [ ] `CartRepositoryIT`, `OrderRepositoryIT` with Testcontainers PostgreSQL.
  - **Done when:** `./mvnw -pl order-service -am verify` passes with the repository tests.

- [ ] **TASK-07 — Cross-cutting web support (correlation IDs, error format)**
  - **Owner:** Member B · **Start:** Nov 2 · **Deadline:** Nov 4 · **Effort:** 3 h · **Depends on:** TASK-02
  - [ ] `CorrelationIdFilter` in `bookstore-common` (`com.bookstore.common.web`): read or create `X-Correlation-Id`, put it in the MDC, echo it in the response.
  - [ ] Register the filter in the four services; add the header to outgoing `RestClient` calls (used later in TASK-17).
  - [ ] A `@RestControllerAdvice` template returning `ErrorResponse` (validation, not found, generic), copied/adapted into each service's `exception` package.
  - [ ] Unit test of the filter.
  - **Done when:** a request with `X-Correlation-Id: test-123` shows `test-123` in the service log and an invalid request returns the `ErrorResponse` JSON.

### Milestone M3 — Core functionality (deadline Nov 6)

- [ ] **TASK-08 — Auth: registration, login, PBKDF2, token issuing**
  - **Owner:** Member A · **Start:** Nov 3 · **Deadline:** Nov 5 · **Effort:** 6 h · **Depends on:** TASK-03, TASK-07
  - [ ] `Pbkdf2PasswordEncoder` bean (`config`); `JwtService` signing tokens with `JWT_SECRET` (claims: `sub`=userId, `role`, `exp`) (`security`).
  - [ ] `AuthService.register` (unique email, validation) and `login` (wrong credentials → 401).
  - [ ] `AuthController`: `POST /api/auth/register`, `POST /api/auth/login`; request validation.
  - [ ] Unit tests (password is never stored in clear text, duplicate email, bad password) and `@WebMvcTest`.
  - **Done when:** register + login work with curl through the service and all Auth tests pass.

- [ ] **TASK-09 — API Gateway: token validation, correlation IDs, routing errors**
  - **Owner:** Member A · **Start:** Nov 4 · **Deadline:** Nov 6 · **Effort:** 6 h · **Depends on:** TASK-08 (token format)
  - [ ] Global `CorrelationIdFilter` (create the id if missing, forward it downstream, return it in the response).
  - [ ] Global `AuthenticationFilter`: public paths from `bookstore.public-paths`; validate the Bearer JWT; forward `X-User-Id`/`X-User-Role`; remove any client-sent `X-User-*` headers; `/api/admin/**` requires `ADMIN`.
  - [ ] JSON errors in the `ErrorResponse` format: 401, 403, 503 when a service is down / times out.
  - [ ] Tests: filter unit tests + routing test with WireMock back-ends.
  - **Done when:** without a token `/api/orders` → 401; with a customer token `/api/admin/orders` → 403; with a stopped service → 503 JSON.

- [ ] **TASK-10 — Inventory contract stubs (WireMock)**
  - **Owner:** Member B (written) + Member A (review) · **Start:** Nov 3 · **Deadline:** Nov 4 · **Effort:** 2 h + 0.5 h review · **Depends on:** TASK-02
  - [ ] One mapping per interaction in `contracts/inventory-api/mappings/`: reserve OK (201), reserve insufficient stock (409), confirm (200), release (204).
  - [ ] Document the provider state each stub needs in its `metadata` (see `contracts/inventory-api/README.md`).
  - **Done when:** the stubs are merged and match `docs/api.md`; both members have reviewed them.

- [ ] **TASK-11 — Order rules, test-driven (README §4.1)**
  - **Owner:** Member B · **Start:** Nov 4 · **Deadline:** Nov 6 · **Effort:** 6 h · **Depends on:** TASK-06, TASK-10
  - [ ] Define `InventoryClient` and `PaymentClient` **interfaces** (`client` package) — no HTTP yet.
  - [ ] **First commit = failing tests** in `OrderServiceTest` (Mockito): empty cart → `EmptyCartException`, no payment call; out of stock → order `REJECTED`, no payment call; payment refused → reservation released, order `PAYMENT_FAILED`; success → reservation confirmed, order `CONFIRMED`, cart emptied; inventory unavailable → `ServiceUnavailableException`.
  - [ ] Second commit = implementation of `OrderService.checkout` that makes the tests pass.
  - **Done when:** the git history shows the tests before the implementation and all five tests pass.

- [ ] **TASK-12 — CI on GitHub and pull-request workflow**
  - **Owner:** Member A · **Start:** Nov 5 · **Deadline:** Nov 6 · **Effort:** 2 h · **Depends on:** TASK-01
  - [ ] Push a branch and check that `ci.yml` builds only the changed modules (path filters) and that the `e2e` job starts the stack.
  - [ ] Fix any runner-specific problem (Testcontainers, Docker build cache).
  - [ ] Make the CI checks required for merging into `main`.
  - **Done when:** a PR touching only `catalog-service` runs only the catalog build + E2E job, and it is green.

- [ ] **TASK-13 — Week 1 review**
  - **Owner:** Both · **Start:** Nov 6 · **Deadline:** Nov 6 · **Effort:** 1 h each · **Depends on:** TASK-01…12
  - [ ] Update the progress tracker; move unfinished work; re-estimate week 2.
  - **Done when:** M1–M3 statuses are updated and week 2 is re-planned if needed.

---

## 3. Week 2 — November 7 – November 13: Feature implementation and integration

### Milestone M4 — All service APIs implemented and contract-verified (deadline Nov 10)

- [ ] **TASK-14 — Catalog API**
  - **Owner:** Member A · **Start:** Nov 7 · **Deadline:** Nov 9 · **Effort:** 6 h · **Depends on:** TASK-04, TASK-07
  - [ ] `GET /api/books` (search, filters, paging), `GET /api/books/{id}`, `GET /api/categories`, `GET /api/authors`.
  - [ ] `POST /api/admin/books`, `PUT /api/admin/books/{id}` with validation (ISBN unique, price ≥ 0).
  - [ ] DTO mapping (entities never leave the service); unit + `@WebMvcTest` tests.
  - **Done when:** all endpoints work through the gateway (`/api/books` public, admin endpoints only with an admin token).

- [ ] **TASK-15 — Inventory API (stock and reservations)**
  - **Owner:** Member B · **Start:** Nov 7 · **Deadline:** Nov 8 · **Effort:** 7 h · **Depends on:** TASK-05, TASK-07, TASK-10
  - [ ] `GET /api/inventory/stock`, `GET /api/inventory/stock/{bookId}`, `PUT /api/admin/inventory/{bookId}`.
  - [ ] `POST /api/inventory/reservations`: all-or-nothing in one transaction, decrements stock, 409 if any line is short, idempotent per `orderId`; concurrency-safe (`@Version` / retry).
  - [ ] `POST /reservations/{id}/confirm`, `DELETE /reservations/{id}` (gives the stock back, only if `RESERVED`).
  - [ ] Unit tests (insufficient stock, release twice, partial availability) + `@WebMvcTest`.
  - **Done when:** reserve → stock decreases; release → stock restored; tests pass.

- [ ] **TASK-16 — Inventory provider contract verification (README §4.2)**
  - **Owner:** Member B (Member A reviews) · **Start:** Nov 9 · **Deadline:** Nov 9 · **Effort:** 3 h · **Depends on:** TASK-10, TASK-15
  - [ ] `InventoryContractVerificationIT`: `@SpringBootTest(webEnvironment = RANDOM_PORT)` + Testcontainers MySQL; for each mapping in `contracts.dir`, prepare the provider state, send the stub's request to the real service, compare status and JSON fields with the stub's response.
  - **Done when:** the test passes, and changing a field name in a stub makes it fail.

- [ ] **TASK-17 — Order Service integrations and simulated Payment**
  - **Owner:** Member B · **Start:** Nov 8 · **Deadline:** Nov 10 · **Effort:** 6 h · **Depends on:** TASK-10, TASK-11
  - [ ] HTTP implementations of `InventoryClient` and `PaymentClient` with `RestClient` (base URLs and timeouts from `bookstore.clients.*`, correlation id forwarded); map 409 → out of stock, connection error/timeout → `ServiceUnavailableException`.
  - [ ] Simulated Payment endpoint `POST /internal/payments` (`payment` package) implementing the rule of TASK-02.
  - [ ] `InventoryClientContractIT`: WireMock loaded with `contracts/inventory-api/mappings`.
  - **Done when:** the consumer contract test passes using exactly the shared stubs.

- [ ] **TASK-18 — Order API (cart, checkout, history, admin)**
  - **Owner:** Member B · **Start:** Nov 9 · **Deadline:** Nov 10 · **Effort:** 5 h · **Depends on:** TASK-11, TASK-17
  - [ ] Cart endpoints (`GET /api/cart`, `POST/PUT/DELETE /api/cart/items…`) using `X-User-Id`.
  - [ ] `POST /api/orders` (checkout), `GET /api/orders` (history), `GET /api/admin/orders?status=`.
  - [ ] `@WebMvcTest` tests for status codes and error bodies (empty cart 400, payment refused, 503).
  - **Done when:** with the stack running, a customer can fill a cart and check out via curl through the gateway, and the three outcomes of README §3.3 can be produced.

### Milestone M5 — Client features working end to end (deadline Nov 13)

- [ ] **TASK-19 — Client foundation, login and registration**
  - **Owner:** Member A · **Start:** Nov 7 · **Deadline:** Nov 9 · **Effort:** 6 h · **Depends on:** TASK-08, TASK-09
  - [ ] `ClientConfig` (gateway URL), `Session` (token, user id, role), `ApiClient` (HttpClient + Jackson, Bearer header, `ErrorResponse` → message, connection refused/timeout → "service unavailable" message), all calls off the JavaFX thread (`Task`).
  - [ ] Main window (replace `main-view.fxml`) with navigation: Catalogue, Cart, My orders, Admin (only for `ADMIN`).
  - [ ] Login and register views with validation and error display.
  - [ ] Unit tests of `ApiClient` against WireMock (success, 4xx, server down).
  - **Done when:** a user can register and log in from the client; with the gateway stopped, a clear message is shown instead of a crash.

- [ ] **TASK-20 — Client catalogue: grid with covers, search and filters**
  - **Owner:** Member A · **Start:** Nov 10 · **Deadline:** Nov 12 · **Effort:** 7 h · **Depends on:** TASK-14, TASK-19 (and TASK-18 for "Add to cart")
  - [ ] Grid of book cards (`TilePane`/`FlowPane`) with covers loaded in background and a placeholder image.
  - [ ] Search field + filters (category, author, price range) + paging.
  - [ ] Book details view with stock availability and "Add to cart" (uses the `CartApi` written by Member B in TASK-21 — agree on its method signatures on Nov 10).
  - **Done when:** all README §3.1 browsing/search features can be demonstrated with the seed data.

- [ ] **TASK-21 — Client cart, checkout and order history**
  - **Owner:** Member B · **Start:** Nov 11 · **Deadline:** Nov 13 · **Effort:** 6 h · **Depends on:** TASK-18, TASK-19
  - [ ] `CartApi`, `OrderApi` service classes (client `service` package).
  - [ ] Cart view (change quantities, remove, total), checkout button.
  - [ ] Clear outcome messages: confirmed, rejected (out of stock — which book), payment refused, service unavailable, empty cart.
  - [ ] Order history view (date, items, total, status).
  - **Done when:** each of the outcomes of README §3.3 is shown with a clear message in the client.

- [ ] **TASK-22 — Client admin views**
  - **Owner:** Member A · **Start:** Nov 11 · **Deadline:** Nov 13 · **Effort:** 6 h · **Depends on:** TASK-14, TASK-15, TASK-18, TASK-19
  - [ ] Books: table + add/edit form with validation (README §3.2).
  - [ ] Stock: table of books with current stock and an "update stock" action.
  - [ ] Orders: table of all orders with status filter.
  - **Done when:** an admin can add a book, set its stock and see a customer's order with its status, all from the client.

- [ ] **TASK-23 — Integration checkpoint (shared)**
  - **Owner:** Both · **Start:** Nov 13 · **Deadline:** Nov 13 · **Effort:** 3 h each · **Depends on:** TASK-14…22
  - [ ] Fresh `docker compose down -v && docker compose up --build --wait`, then walk through **every** item of the integration checklist (section 5) together.
  - [ ] Write the bug list as GitHub issues (label `bug`, owner assigned); update the progress tracker.
  - **Done when:** every README functional requirement has been demonstrated at least once or has an issue assigned.

---

## 4. Week 3 — November 14 – November 20: Final integration, testing, debugging, documentation, delivery

### Milestone M6 — Automated E2E test and CD pipelines working (deadline Nov 17)

- [ ] **TASK-24 — End-to-end test (README §4.4)**
  - **Owner:** Member B · **Start:** Nov 14 · **Deadline:** Nov 16 · **Effort:** 5 h · **Depends on:** TASK-23
  - [ ] `PurchaseFlowIT` in `e2e-tests` (only through the gateway): register a unique user, log in, read the stock of two books, add both to the cart, check out, assert `CONFIRMED`, assert each stock decreased by the purchased quantity.
  - [ ] Make it independent of previous runs (unique email, read stock before buying).
  - [ ] Check that the CI `e2e` job runs it against `docker compose up --wait`.
  - **Done when:** the test passes locally and in GitHub Actions.

- [ ] **TASK-25 — Resilience and error-handling hardening**
  - **Owner:** Member A · **Start:** Nov 14 · **Deadline:** Nov 15 · **Effort:** 4 h · **Depends on:** TASK-23
  - [ ] Stop each service in turn (`docker compose stop <svc>`) and check the client message and the gateway/Order 503 response.
  - [ ] Check timeouts (gateway `response-timeout`, Order `read-timeout`) and that a failed payment call releases the reservation.
  - [ ] Check correlation IDs appear in the logs of gateway, Order and Inventory for one checkout.
  - **Done when:** no stack trace or frozen window is ever shown to the user for an unavailable service.

- [ ] **TASK-26 — Deployment to the demo machine (README §5.2)**
  - **Owner:** Member A · **Start:** Nov 14 · **Deadline:** Nov 17 · **Effort:** 6 h · **Depends on:** TASK-12, TASK-23
  - [ ] Prepare the demo machine (Docker, `~/bookstore/.env` from `.env.example` with a real `JWT_SECRET`, SSH key for GitHub Actions, GHCR pull access or public packages).
  - [ ] Add secrets `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_SSH_KEY` (+ `DEPLOY_PORT`) and variable `DEPLOY_ENABLED=true`.
  - [ ] Merge to `main` and verify: images pushed to GHCR, `scripts/deploy.sh` pulls/restarts, all `/health` checks pass.
  - [ ] **Rollback test:** deploy a commit whose service fails its health check and verify the previous tag is restored.
  - **Done when:** a merge to `main` deploys automatically and a broken deployment rolls back by itself.

- [ ] **TASK-27 — Versioned images, installers and GitHub Release (README §5.3–5.4)**
  - **Owner:** Member B · **Start:** Nov 15 · **Deadline:** Nov 17 · **Effort:** 5 h · **Depends on:** TASK-23
  - [ ] Run `scripts/package-client.sh` locally on your OS; check that the installed app starts and reaches the gateway.
  - [ ] Push a test tag `v0.9.0`; verify versioned images on GHCR, installers for Linux/Windows/macOS and `docker-compose.yml` attached to the release.
  - [ ] Fix runner-specific jpackage problems (WiX on Windows, signing warnings on macOS); delete the test release afterwards.
  - **Done when:** the `v0.9.0` release contains the three installers and `docker-compose.yml`, and `docker compose up` with that file starts version `v0.9.0`.

### Milestone M7 — Stabilised, documented, delivered (deadline Nov 20)

- [ ] **TASK-28 — Test review and bug fixing (shared)**
  - **Owner:** Both (each fixes the bugs in their own components) · **Start:** Nov 17 · **Deadline:** Nov 19 · **Effort:** 5 h each · **Depends on:** TASK-23…27
  - [ ] Go through the testing checklist (section 6); add missing tests.
  - [ ] Close all `bug` issues or document the known limitations.
  - **Done when:** all checklists in sections 5 and 6 are ticked and CI is green on `main`.

- [ ] **TASK-29 — Documentation (shared)**
  - **Owner:** Member A: user guide · Member B: testing & CI/CD guide · **Start:** Nov 17 · **Deadline:** Nov 19 · **Effort:** 3 h each · **Depends on:** TASK-28
  - [ ] `docs/user-guide.md`: customer and admin walkthrough with screenshots, demo accounts.
  - [ ] `docs/testing.md`: how each README §4 test type is implemented and run; CI/CD and release procedure.
  - [ ] Update `docs/architecture.md` and `docs/api.md` to match the final code. **Do not modify the professor's README.**
  - **Done when:** someone new can run, use and test the system using only the docs.

- [ ] **TASK-30 — Final release, demo rehearsal and submission**
  - **Owner:** Both · **Start:** Nov 19 · **Deadline:** **Nov 20** · **Effort:** 3 h each · **Depends on:** TASK-28, TASK-29
  - [ ] Tag `v1.0.0`; verify the GitHub Release assets and the deployed demo machine.
  - [ ] Rehearse the demo script: register → browse/search → buy two books → history; admin: add book, update stock, view orders; show a refused payment and an out-of-stock order; stop a service to show the error message; show CI, deployment and release runs.
  - [ ] Submit according to the professor's instructions.
  - **Done when:** the final delivery checklist (section 7) is complete.

---

## 5. Integration checklist

Run on a fresh stack (`docker compose down -v && docker compose up --build --wait`) using the JavaFX client.

- [ ] All five services report `UP` on `/health`; only the gateway port is published in `docker-compose.yml`.
- [ ] The client is configured with the gateway URL only (no direct service URLs).
- [ ] Register a new customer; log in; the token is sent on every protected call.
- [ ] Catalogue grid shows covers (placeholder when a cover is missing); search and every filter work.
- [ ] Add books to the cart; change quantities; remove an item; totals are correct.
- [ ] Checkout success → order `CONFIRMED`, cart emptied, stock decreased.
- [ ] Checkout with insufficient stock → order rejected, **no** payment call (check logs), stock unchanged.
- [ ] Checkout with refused payment → order not confirmed, reservation released, stock restored.
- [ ] Checkout with an empty cart → clear message.
- [ ] Order history shows the customer's orders with statuses.
- [ ] Admin: add a book, edit it, update its stock, view all orders and statuses.
- [ ] Customer token on an admin endpoint → 403; no token on a protected endpoint → 401.
- [ ] Stop Inventory / Order / Catalog / Auth / gateway one at a time → the client shows a clear "service unavailable" message.
- [ ] One correlation ID can be followed through gateway → Order → Inventory logs.

## 6. Testing checklist

- [ ] **Unit (TDD, README §4.1):** empty cart, out-of-stock items, refused payment — tests committed **before** the implementation (TASK-11).
- [ ] Unit tests for Auth (hashing, duplicate email, bad password), Gateway filters, Inventory reservation rules, client `ApiClient` error handling.
- [ ] **Contract (README §4.2):** Order's expectations of Inventory are WireMock stubs in `contracts/inventory-api`; consumer test (Order) and provider verification against the real Inventory service both pass.
- [ ] **Repository (README §4.3):** Testcontainers tests for Auth, Catalog, Order (PostgreSQL) and Inventory (MySQL).
- [ ] **End-to-end (README §4.4):** register a user → purchase two books → stock levels decreased, run on the composed stack through the gateway.
- [ ] `./mvnw verify` passes locally; all CI jobs green on `main`.
- [ ] CI path filters: a change in one service only builds that service (plus the E2E job).
- [ ] Manual client test of every view (customer and admin) on at least two operating systems.

## 7. Final delivery checklist

- [ ] All mandatory README requirements are covered (see the traceability matrix in section 9).
- [ ] `main` is green; the demo machine runs the latest `main` and all `/health` checks pass.
- [ ] Rollback has been demonstrated at least once (TASK-26).
- [ ] Version tag `v1.0.0` pushed; versioned images on GHCR.
- [ ] GitHub Release `v1.0.0` contains the JavaFX installers and `docker-compose.yml`.
- [ ] Documentation up to date (`docs/`), demo accounts documented, no secrets committed (`.env` ignored).
- [ ] The professor's `README.md` is unchanged.
- [ ] Demo rehearsed; submission done before **November 20, 2026**.

## 8. Definition of Done (whole project)

The project is done when:

1. Every functional requirement of README §3 works in the JavaFX client against the composed stack, through the API Gateway only.
2. The order workflow follows README §3.3 exactly (reserve → pay → confirm / release / reject) and every failure produces a clear user message.
3. Each service owns its database (PostgreSQL for Auth, Catalog, Order; MySQL for Inventory) with Flyway-managed schemas.
4. All four test types of README §4 exist, pass locally and in CI, and the TDD order-rule tests predate their implementation in git history.
5. The four workflows (CI with path filters + E2E, deployment with health checks and rollback, versioned images, GitHub Release with installers and `docker-compose.yml`) have each run successfully at least once.
6. Code is reviewed (every change merged by pull request), follows the package conventions, and contains no secrets.
7. Documentation lets a new person build, run, test and use the system.

**Per-task Definition of Done:** code + tests merged into `main` via a reviewed pull request, CI green,
the task's "Done when" criterion demonstrated, checkbox ticked, tracker updated.

---

## 9. Requirements traceability matrix

| README requirement | Task(s) |
| --- | --- |
| §2 API Gateway: routing, token validation, correlation IDs | TASK-09, TASK-07, TASK-25 |
| §2 Auth: registration, login, PBKDF2, tokens (PostgreSQL) | TASK-03, TASK-08 |
| §2 Catalog: books, authors, categories, search (PostgreSQL) | TASK-04, TASK-14 |
| §2 Inventory: stock levels, reservations (MySQL) | TASK-05, TASK-15 |
| §2 Order: carts, orders, Inventory + simulated Payment calls (PostgreSQL) | TASK-06, TASK-11, TASK-17, TASK-18 |
| §3.1 Catalogue grid with covers, search and filters | TASK-04, TASK-14, TASK-20 |
| §3.1 Cart, checkout, order history | TASK-18, TASK-21 |
| §3.2 Admin: add/edit books, update stock, view orders | TASK-14, TASK-15, TASK-18, TASK-22 |
| §3.3 Order processing rules | TASK-11, TASK-15, TASK-17 |
| §3.3 Clear client errors when a service is unavailable | TASK-09, TASK-17, TASK-19, TASK-21, TASK-25 |
| §4.1 TDD unit tests (empty cart, out of stock, refused payment) | TASK-11 |
| §4.2 WireMock contract tests verified against real Inventory | TASK-10, TASK-16, TASK-17 |
| §4.3 Testcontainers repository tests | TASK-03, TASK-04, TASK-05, TASK-06 |
| §4.4 E2E: register, buy two books, stock decreased | TASK-24 |
| §5.1 CI on push, path filters, service workflows, `docker compose up --wait`, E2E via gateway | TASK-12, TASK-24 |
| §5.2 Deploy on `main`: GHCR, SSH, pull/up, `/health`, rollback | TASK-26 |
| §5.3 Versioned images on tags | TASK-27 |
| §5.4 Release with client installers + `docker-compose.yml` | TASK-27, TASK-30 |

## 10. Risks and mitigations

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Order ↔ Inventory integration breaks late | Checkout fails at the checkpoint | Contract stubs fixed on Nov 4 (TASK-10), verified on both sides by Nov 10 (TASK-16/17). |
| Concurrent reservations oversell stock | Wrong stock levels | Single transaction + optimistic locking (`@Version`) + unit test (TASK-15). |
| Client blocked waiting for backend | Member A idle in week 2 | Client `ApiClient` tested against WireMock (TASK-19); API shapes fixed in TASK-02. |
| jpackage fails on a CI OS (WiX, macOS) | Missing installer asset | Test tag `v0.9.0` three days before the deadline (TASK-27). |
| No demo machine / SSH access | Deployment cannot be shown | Arrange the machine in week 2 (university VM, cloud free tier or a teammate's PC); TASK-26 starts Nov 14. |
| Testcontainers slow or flaky in CI | Red builds | Pinned images, `-pl <module> -am` builds, test reports uploaded as artifacts. |
| Scope creep | Mandatory features late | Only README features are planned; extras below are optional and only after M5. |

## 11. Assumptions and open questions

- **Token = JWT** signed with HMAC-SHA256 (secret shared by Auth and Gateway). The README only says "token".
- **Simulated Payment** is an endpoint inside the Order Service (`/internal/payments`), because the README lists exactly five services; its URL is configurable.
- **Payment rule** is deterministic (to be fixed in TASK-02) so that refused payments are reproducible.
- **Reservation semantics:** reserving decrements available stock; release restores it; confirm makes it final.
- **Covers** are image URLs stored in the catalogue (seed data uses public cover URLs); the client shows a placeholder when loading fails.
- **Demo machine** for §5.2 is not specified in the README — **ask the professor** whether one is provided.
- **Installer formats:** `.deb` (Linux), `.msi` (Windows), `.dmg` (macOS) — confirm which platforms the professor expects.
- **Submission format** (repository link, report, presentation?) — **ask the professor** in week 1.

## 12. Optional improvements (only after M5, never at the expense of mandatory work)

- [ ] OpenAPI/Swagger UI for each service.
- [ ] JaCoCo coverage report in CI.
- [ ] Book cover upload by admins (instead of URLs).
- [ ] Token refresh / logout.
