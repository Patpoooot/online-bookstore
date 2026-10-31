package com.bookstore.client;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

import java.io.IOException;
import java.util.Objects;

/**
 * JavaFX application. Loads the main window; navigation between the login, catalogue,
 * cart, order history and admin views is implemented in the {@code controller} package.
 */
public class BookstoreApp extends Application {

    @Override
    public void start(Stage stage) throws IOException {
        Parent root = FXMLLoader.load(Objects.requireNonNull(
                getClass().getResource("view/main-view.fxml"), "main-view.fxml not found"));
        Scene scene = new Scene(root, 1100, 750);
        scene.getStylesheets().add(Objects.requireNonNull(
                getClass().getResource("css/app.css")).toExternalForm());
        stage.setTitle("Online Bookstore");
        stage.setScene(scene);
        stage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}
