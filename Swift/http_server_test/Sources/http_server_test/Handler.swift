import NIO
import Foundation
import NIOHTTP1

class Handler:ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart
    //typealias InboundIn = ByteBuffer
    //typealias OutboundOut = ByteBuffer
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        print("I'am the handler")
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
        /*
        var response = HTTPResponseHead(version: HTTPVersion(major: 1, minor: 1), status: .ok)
        response.headers.replaceOrAdd(name: "Content-Type", value: "text/html")
        let buff = self.unwrapInboundIn(data)
        let str = buff.getString(at: 0, length: buff.readableBytes) ?? "DEFAULT MESSAGE"
        let sourceAddress = context.channel.remoteAddress!
        let sourceIP = sourceAddress.ipAddress
        print("Received string: \(str.trimmingCharacters(in: .whitespacesAndNewlines)) from \(sourceIP ?? "UNKNOWN")")
        var outBuff = context.channel.allocator.buffer(capacity: 100)
        outBuff.writeString("<html><body><h2><Strong> Hello from http server (JS) </h2></body></html>\n")
        context.writeAndFlush(self.wrapOutboundOut(outBuff),promise: nil)
        */
        /*var buffer = self.unwrapInboundIn(data)
        //var req:HTTPServerRequestPart 
        var req:HTTPRequestHead = HTTPRequestHead(version: HTTPVersion(major: 1, minor: 1), method: .GET, uri: "/")

        switch buffer {
            case .head(let request):
            //let req = HTTPServerRequestPart.head(request)
            let req = request 
                break

            case .body(_):break

            case .end(_):break

        }
        //let readableBytes = req.readableBytes
        //if let received = req.readString(length: readableBytes) {
        //    print(received)
        //}
        let response = httpResponseHead(request: req, status: .ok)
        context.write(self.wrapOutboundOut(.head(response)), promise: nil)
        var buff = context.channel.allocator.buffer(capacity: 100)
        buff.writeString("HOLA")
        context.write(self.wrapOutboundOut(.body(.byteBuffer(buff))), promise: nil)
        */
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