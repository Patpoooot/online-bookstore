#!/usr/bin/env bash
# Runs ON THE DEMO MACHINE (copied there by .github/workflows/deploy.yml).
#
#   ./deploy.sh <new-image-tag>
#
# 1. Remembers the image tag currently deployed (IMAGE_TAG in .env).
# 2. Pulls and restarts the stack with the new tag.
# 3. Checks GET /health of every service.
# 4. If any health check fails, rolls back to the previous tag and exits with an error.
#
# Expected layout on the demo machine:  ~/bookstore/{docker-compose.yml,.env,scripts/deploy.sh}
# (the script works in the parent directory of scripts/, i.e. where docker-compose.yml is).
set -euo pipefail

NEW_TAG="${1:?usage: deploy.sh <image-tag>}"
cd "$(dirname "$0")/.."

# service:port pairs checked from inside each container (only the gateway is published)
SERVICES=("api-gateway:8080" "auth-service:8081" "catalog-service:8082" "inventory-service:8083" "order-service:8084")
HEALTH_RETRIES=${HEALTH_RETRIES:-30}   # x 5 s

touch .env
PREVIOUS_TAG="$(grep -E '^IMAGE_TAG=' .env | cut -d= -f2 || true)"
PREVIOUS_TAG="${PREVIOUS_TAG:-latest}"

set_tag() {
  if grep -qE '^IMAGE_TAG=' .env; then
    sed -i "s/^IMAGE_TAG=.*/IMAGE_TAG=$1/" .env
  else
    echo "IMAGE_TAG=$1" >> .env
  fi
}

start_stack() {
  set_tag "$1"
  docker compose pull
  docker compose up -d
}

healthy() {
  local svc port
  for entry in "${SERVICES[@]}"; do
    svc="${entry%%:*}"; port="${entry##*:}"
    local ok=false
    for _ in $(seq 1 "$HEALTH_RETRIES"); do
      if docker compose exec -T "$svc" curl -fsS "http://localhost:${port}/health" >/dev/null 2>&1; then
        ok=true; break
      fi
      sleep 5
    done
    if [ "$ok" != true ]; then
      echo "Health check FAILED for $svc"
      return 1
    fi
    echo "Health check OK for $svc"
  done
}

echo "Deploying image tag '$NEW_TAG' (previous: '$PREVIOUS_TAG')"
start_stack "$NEW_TAG"

if healthy; then
  echo "Deployment of '$NEW_TAG' succeeded."
  exit 0
fi

echo "Rolling back to '$PREVIOUS_TAG'..."
start_stack "$PREVIOUS_TAG"
healthy || echo "WARNING: the rolled-back stack is not healthy either."
exit 1
