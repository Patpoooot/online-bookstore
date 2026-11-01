# syntax=docker/dockerfile:1
# Build context: repository root (the module needs the parent POM and bookstore-common).
#   docker build -f auth-service/Dockerfile -t bookstore-auth-service .

# ---- Build stage ----
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /workspace
COPY . .
RUN --mount=type=cache,target=/root/.m2 \
    mvn -B -q -pl auth-service -am package -DskipTests

# ---- Runtime stage ----
FROM eclipse-temurin:21-jre
# curl is used by the Docker health check (GET /health)
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --system --create-home app
USER app
WORKDIR /app
COPY --from=build /workspace/auth-service/target/auth-service.jar app.jar
EXPOSE 8081
HEALTHCHECK --interval=10s --timeout=3s --start-period=60s --retries=10 \
    CMD curl -fsS http://localhost:8081/health || exit 1
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "-jar", "app.jar"]
