#!/usr/bin/env bash
# Starts only the four databases (ports 5433/5434/5435/3307 on localhost) so that the
# services can be run from the IDE or with ./mvnw spring-boot:run.
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose up -d --wait auth-db catalog-db order-db inventory-db
docker compose ps
