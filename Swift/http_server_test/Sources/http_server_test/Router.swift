import Logging
import Lifecycle
import NIO
import Foundation
import NIOHTTP1

class Router{
    var request:Handler.InboundIn?

    func setRequest(_ request:Handler.InboundIn) {
        self.request = request
    }

    func requestExists() -> Bool {
        return self.request != nil
    }

    func move(context: ChannelHandlerContext) -> String {
        switch request {
            case .head(let headers):
                print("Received headers: \(headers)")
                print("**************************************************")
                print(headers.uri)
                print("**************************************************")
                var html:String = ""
                if (headers.uri == "/ok") {
                    html = """
                    <html>
                    <head>
                        <title>NIO</title>
                    </head>
                    <body>
                        <h1>Hola, esto es la página de OK </h1>
                    </body>
                    </html>
                    """
                } else if (headers.uri == "/crash") {
                    let a:String? = nil
                    print(a!) // produce error de ejecución
                    html = """
                    <html>
                    <head>
                        <title>NIO</title>
                    </head>
                    <body>
                        <h1>Hola, esto es un CRASH</h1>
                    </body>
                    </html>
                    """
                } else {
                    html = """
                    <html>
                    <head>
                        <title>NIO</title>
                    </head>
                    <body>
                        <h1>Hola, esto es un servidor http simple hecho con swiftNIO</h1>
                    </body>
                    </html>
                    """
                }
                return html
            default:
                if let r = request {
                    return "Ignoring part: \(r)"
                } else {
                    return ""
                }
                
        } 
    }
}