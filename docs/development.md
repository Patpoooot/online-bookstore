# Development guide

## Prerequisites

- JDK 21 (Temurin recommended) — Maven is provided by the wrapper (`./mvnw`, `mvnw.cmd` on Windows)
- Docker with Docker Compose v2 (needed for Testcontainers and for running the stack)
- An IDE with Maven support (IntelliJ IDEA or Eclipse)

## Repository layout

```
online-bookstore/
├── pom.xml                  parent POM (versions, plugins, module list)
├── bookstore-common/        shared header names, ErrorResponse, correlation-id filter
├── api-gateway/             Spring Cloud Gateway (routes in application.yml)
├── auth-service/            ┐
├── catalog-service/         │ Spring Boot services: controller / service / repository /
├── inventory-service/       │ model / dto / config / exception (+ client, payment in order)
├── order-service/           ┘ each with Dockerfile, application.yml, Flyway migrations
├── bookstore-client/        JavaFX client (controller / service / model / config / util, FXML in resources)
├── e2e-tests/               end-to-end tests against the composed stack (-Pe2e)
├── contracts/inventory-api/ WireMock stubs = Order -> Inventory contract
├── docker-compose.yml       full stack from GHCR images (demo machine, release asset)
├── docker-compose.override.yml  local/CI: build images from source, publish debug ports
├── .env.example             configuration template (copy to .env)
├── scripts/                 deploy.sh (demo machine), package-client.sh (jpackage), dev-db-up.sh
├── docs/                    architecture, API, this guide
└── .github/workflows/       ci, service-ci, deploy, release
```

## Common commands

Build everything and run unit tests (no Docker needed):

```bash
./mvnw verify -DskipITs
```

Build everything and run unit + integration tests (Testcontainers, needs Docker):

```bash
./mvnw verify
```

Build and test one service only (what CI does):

```bash
./mvnw -pl order-service -am verify
```

Run the whole stack (builds the images from source):

```bash
docker compose up --build --wait
```

Run the end-to-end tests against the running stack:

```bash
./mvnw -pl e2e-tests -am verify -Pe2e
```

Stop the stack and delete its data:

```bash
docker compose down -v
```

### Running a service from the IDE

Start only the databases, then run the `*Application` class (default ports and JDBC URLs in
each `application.yml` match the ports published by `docker-compose.override.yml`):

```bash
scripts/dev-db-up.sh
```

```bash
./mvnw -pl catalog-service spring-boot:run
```

### Running the JavaFX client

```bash
./mvnw -pl bookstore-client -am install -DskipTests
```

```bash
./mvnw -pl bookstore-client javafx:run
```

## Ports

| Component | Port (localhost) |
| --- | --- |
| API Gateway | 8080 |
| Auth / Catalog / Inventory / Order | 8081 / 8082 / 8083 / 8084 |
| auth-db / catalog-db / order-db (PostgreSQL) | 5433 / 5434 / 5435 |
| inventory-db (MySQL) | 3307 |

Every service exposes `GET /health`.

## Conventions

- **Packages:** `com.bookstore.<service>.{controller,service,repository,model,dto,config,exception}`.
  Controllers stay thin; business rules live in `service`; entities never leave the service (map to DTOs).
- **Tests:** `*Test` = unit/web tests (Surefire, fast, no Docker); `*IT` = integration tests (Failsafe:
  Testcontainers, contracts). Order rules are written **test first** (README §4.1).
- **Database changes:** never edit an applied migration; add `V<n>__description.sql`.
- **Git workflow:** one branch per task (`feature/TASK-xx-short-name`), small pull requests reviewed by
  the other member, `main` always green. Reference the task id in commits (`TASK-12: add reservation endpoint`).
- **Configuration:** every environment-specific value is an environment variable with a local default
  (see `.env.example`). Never commit `.env` or real secrets.
