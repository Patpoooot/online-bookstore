# Inventory API contract (consumer: Order Service, provider: Inventory Service)

This directory is the **single source of truth** for what the Order Service expects from the
Inventory API. It contains standard [WireMock stub mappings](https://wiremock.org/docs/stubbing/)
(`mappings/*.json`), one file per interaction.

| Side | Test | What it does |
| --- | --- | --- |
| Consumer | `order-service/src/test/java/com/bookstore/order/contract/*IT` | Starts WireMock with these mappings and tests the Order Service's `InventoryClient` against them. |
| Provider | `inventory-service/src/test/java/com/bookstore/inventory/contract/*IT` | Replays each mapping's request against the **real** Inventory Service (Testcontainers MySQL) and checks the status code and the JSON fields of the stubbed response. |

Both modules receive the path of this directory through the `contracts.dir` system property
(configured in their `pom.xml`).

Interactions to cover (TASK-10): reserve stock (success), reserve stock (insufficient stock → 409),
release a reservation, confirm a reservation. Keep stubs **deterministic** (fixed book ids and
quantities) and document the provider state each one needs (e.g. "book 1 has 10 copies") in the
mapping's `metadata` field so the provider test can prepare it.
