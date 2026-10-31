/**
 * HTTP clients for the API Gateway (java.net.http.HttpClient + Jackson). They run calls off the JavaFX thread
 * (e.g. with {@code javafx.concurrent.Task}) and translate connection errors / error responses into clear user messages.
 */
package com.bookstore.client.service;
