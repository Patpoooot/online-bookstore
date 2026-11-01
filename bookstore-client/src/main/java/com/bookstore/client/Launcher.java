package com.bookstore.client;

/**
 * Plain entry point used by the packaged application (jpackage / {@code java -jar}).
 * A main class that does not extend {@link javafx.application.Application} lets JavaFX
 * run from the classpath without a module descriptor.
 */
public final class Launcher {

    private Launcher() {
    }

    public static void main(String[] args) {
        BookstoreApp.main(args);
    }
}
