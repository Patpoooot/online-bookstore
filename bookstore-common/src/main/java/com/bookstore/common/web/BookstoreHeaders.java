package com.bookstore.common.web;

/**
 * HTTP header and MDC names shared by the API Gateway and all services.
 */
public final class BookstoreHeaders {

    /** Correlation ID created (or forwarded) by the API Gateway for every request. */
    public static final String CORRELATION_ID = "X-Correlation-Id";

    /** MDC key under which the correlation ID is logged. */
    public static final String CORRELATION_ID_MDC_KEY = "correlationId";

    /** Authenticated user id, added by the gateway after token validation. */
    public static final String USER_ID = "X-User-Id";

    /** Authenticated user role ({@code CUSTOMER} or {@code ADMIN}), added by the gateway. */
    public static final String USER_ROLE = "X-User-Role";

    private BookstoreHeaders() {
    }
}
