/**
 * Cross-cutting web helpers shared by the servlet-based services, e.g. the
 * {@code CorrelationIdFilter} (TASK-07) that copies {@link com.bookstore.common.web.BookstoreHeaders#CORRELATION_ID}
 * into the logging MDC and onto outgoing calls.
 */
package com.bookstore.common.web;
