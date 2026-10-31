package com.bookstore.gateway;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

/**
 * Smoke test: the gateway starts and its route configuration is valid
 * (no back-end service needs to be running).
 */
@SpringBootTest
class ApiGatewayApplicationTest {

    @Test
    void contextLoads() {
    }
}
