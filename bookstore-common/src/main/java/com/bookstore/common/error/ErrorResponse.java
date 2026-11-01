package com.bookstore.common.error;

import java.time.Instant;

/**
 * Uniform JSON error body returned by every service, so that the JavaFX client can
 * always display a clear message.
 *
 * @param status        HTTP status code
 * @param error         short machine-readable code (e.g. {@code OUT_OF_STOCK}, {@code PAYMENT_REFUSED})
 * @param message       human-readable message, safe to show to the user
 * @param path          request path
 * @param correlationId correlation ID of the request (helps finding the logs)
 * @param timestamp     when the error happened
 */
public record ErrorResponse(int status, String error, String message, String path,
                            String correlationId, Instant timestamp) {
}
