/**
 * End-to-end scenario ({@code PurchaseFlowIT}, TASK-24) against the composed stack, through the
 * API Gateway only ({@code System.getProperty("gateway.url")}):
 * <ol>
 *   <li>register a user (and log in to obtain a token);</li>
 *   <li>purchase two books (add to cart, checkout);</li>
 *   <li>verify that the stock levels decreased accordingly.</li>
 * </ol>
 */
package com.bookstore.e2e;
