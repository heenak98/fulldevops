package com.heena.devops;

import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;

public class App {
    public static void main(String[] args) throws IOException {
        HttpServer server = HttpServer.create(new InetSocketAddress(8081), 0);
        server.createContext("/", new HelloHandler());
        server.setExecutor(null); // creates a default executor
        System.out.println("Server started on port 8081");
        server.start();
    }

    static class HelloHandler implements HttpHandler {
        public void handle(HttpExchange exchange) throws IOException {
            String response = "Hello from Java DevOps App!";
            exchange.sendResponseHeaders(200, response.length());
            OutputStream os = exchange.getResponseBody();
            os.write(response.getBytes());
            os.close();
        }
    }
}
