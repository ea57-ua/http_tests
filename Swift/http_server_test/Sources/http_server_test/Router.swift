import Logging
import Lifecycle
import NIO
import Foundation
import NIOHTTP1

class Router:Handler{
    let componentlifecycle: ComponentLifecycle = ComponentLifecycle(label: "SubSystem")
    var request:Handler.InboundIn

    init(_ lifecycle: ServiceLifecycle,_ req:Handler.InboundIn) {
        lifecycle.register(componentlifecycle)
        lifecycle.start { error in
            if let error = error {
                print("Lifecycle failed starting  ☠️: \(error)")
            } else {
                print("Lifecycle started successfully 🚀")
            }   
        } 
        request = req
    }

    func move(context: ChannelHandlerContext) {
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
                let responseHeaders = HTTPHeaders([("content-type", "text/html")])
                let responseData = context.channel.allocator.buffer(string: html)
                let responseHead = HTTPResponseHead(version: .init(major: 1, minor: 1), status: .ok, headers: responseHeaders)
                let responsePartHead = HTTPServerResponsePart.head(responseHead)
                context.write(self.wrapOutboundOut(responsePartHead), promise: nil)
                let responsePartBody = HTTPServerResponsePart.body(.byteBuffer(responseData))
                context.write(self.wrapOutboundOut(responsePartBody), promise: nil)
                let responsePartEnd = HTTPServerResponsePart.end(nil)
                context.writeAndFlush(self.wrapOutboundOut(responsePartEnd), promise: nil)
            default:
                print("Ignoring part: \(request)")
        } 
    }
}