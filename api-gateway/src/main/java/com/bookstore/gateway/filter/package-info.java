/**
 * Global gateway filters: {@code CorrelationIdFilter} (create/forward {@code X-Correlation-Id})
 * and {@code AuthenticationFilter} (validate the Bearer token, forward {@code X-User-Id} /
 * {@code X-User-Role}, reject non-admins on {@code /api/admin/**}).
 */
package com.bookstore.gateway.filter;
