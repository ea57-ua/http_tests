import java.net.InetSocketAddress;
import com.sun.net.httpserver.HttpServer;

public class HttpServerTest {
    private String host;
    private int port;

    public HttpServerTest(String host, int port) {
        this.host = host;
        this.port = port;
    }
    public static void main(String[] args) throws Exception{
        HttpServerTest myhttpserver = new HttpServerTest("127.0.0.1", 8080);
        HttpServer server = HttpServer.create(new InetSocketAddress(myhttpserver.host, myhttpserver.port), 0);
        server.createContext("/", new HttpHandlerTest());
        server.start();
        System.out.println("Starting http server at " + myhttpserver.host + ":" + myhttpserver.port);
    }
}