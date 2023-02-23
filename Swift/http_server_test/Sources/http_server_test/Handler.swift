import NIO
import Foundation
import NIOHTTP1
import Backtrace
import Lifecycle
import Logging

class Handler:ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart
    let logger = Logger(label: "Lifecycle")
    let lifecycle = ServiceLifecycle(configuration: ServiceLifecycle.Configuration(label: "http", installBacktrace: true))

    /*init() {
        lifecycle.start { error in
            if let error = error {
                self.logger.error("failed starting \(self) ☠️: \(error)")
            } else {
                self.logger.info("\(self) started successfully 🚀")
            }   
        } 
    }*/

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        print("I'am the handler")
        let requestPart = self.unwrapInboundIn(data)
        let router = Router(lifecycle, requestPart)
        router.move(context: context)
    }

    func channelActive(context: ChannelHandlerContext) {
        print("New connection established.")
    }

    func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: \(error.localizedDescription)")
        context.close(promise: nil)
    }
}


/*
lifecycle.registerShutdown(
            label: "group", 
            .sync (stop)
        )
        lifecycle.start { error in
            // start completion handler.
            // if a startup error occurred you can capture it here
            if let error = error {
                self.logger.error("failed starting \(self) ☠️: \(error)")
            } else {
                self.logger.info("\(self) started successfully 🚀")
            }
        }
*/

/*
switch requestPart {
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
        print("Ignoring part: \(requestPart)")
} 
*/