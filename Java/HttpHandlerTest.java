import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;

import com.sun.net.httpserver.Headers;
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
        Headers h = exchange.getResponseHeaders();
        File newFile = new File("index.html");
       
        String line;
        String response = "";

        try {
            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(new FileInputStream(newFile)));
            while ((line = bufferedReader.readLine()) != null){
                response += line;
            }
            bufferedReader.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        h.add("Content-Type", "text/html");
        try {
            exchange.sendResponseHeaders(200, response.length());
            OutputStream os = exchange.getResponseBody();
            os.write(response.getBytes());
            os.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        
    }
} 