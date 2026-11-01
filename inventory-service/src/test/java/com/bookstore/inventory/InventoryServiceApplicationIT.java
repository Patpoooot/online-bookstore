package com.bookstore.inventory;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;

/**
 * Smoke test: the application context starts against a real database and the
 * Flyway migrations apply cleanly. Requires Docker (Testcontainers).
 */
@SpringBootTest
@Import(TestcontainersConfiguration.class)
class InventoryServiceApplicationIT {

    @Test
    void contextLoads() {
    }
}
