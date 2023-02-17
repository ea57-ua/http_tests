import NIO
import Foundation
import NIOHTTP1
import Backtrace
import Lifecycle

struct SubSystem {
    let lifecycle = ComponentLifecycle(label: "SubSystem")
    let subsystem: SubSubSystem

    init() {
        self.subsystem = SubSubSystem()
        self.lifecycle.register(self.subsystem.lifecycle)
    }

    struct SubSubSystem {
        let lifecycle = ComponentLifecycle(label: "SubSubSystem")

        init() {
            self.lifecycle.register(self.lifecycle) // ?
        }
    }
}

class Handler:ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart
    //typealias InboundIn = ByteBuffer
    //typealias OutboundOut = ByteBuffer
    let lifecycle = ServiceLifecycle()
    let subsystem = SubSystem()
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        print("I'am the handler")
        lifecycle.register(subsystem.lifecycle)
        lifecycle.start { error in 
            if let error = error {
                print("failed starting \(self) ☠️: \(error)")
            } else {
                print("\(self) started successfully 🚀")
            }
        }
        let requestPart = self.unwrapInboundIn(data)
        switch requestPart {
            case .head(let headers):
                print("Received headers: \(headers)")
                let html = """
                <html>
                <head>
                    <title>NIO</title>
                </head>
                <body>
                    <h1>Hola, esto es un servidor http simple hecho con swiftNIO</h1>
                </body>
                </html>
                """
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