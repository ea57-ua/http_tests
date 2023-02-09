import java.io.IOException;
import java.nio.charset.StandardCharsets;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;

public class HttpHandlerTest implements HttpHandler{
    @Override
    public void handle(HttpExchange exchange) throws IOException{
        switch (exchange.getRequestMethod()){
            case "GET": handleGet(exchange);
                        break;
            default:    System.out.println("not get");
        }
    }

    public void handleGet(HttpExchange exchange) {
        byte[] message = "Hola\n".getBytes(StandardCharsets.UTF_8);
        try {
            exchange.sendResponseHeaders(200, message.length);
            exchange.getResponseBody().write(message);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
} 