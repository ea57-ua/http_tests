import NIO
import Foundation
import NIOHTTP1

class Handler:ChannelInboundHandler {
    //typealias InboundIn = HTTPServerRequestPart
    //typealias OutboundOut = HTTPServerResponsePart
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer
    private func httpResponseHead(request: HTTPRequestHead, status: HTTPResponseStatus, headers: HTTPHeaders = HTTPHeaders()) -> HTTPResponseHead {
    var head = HTTPResponseHead(version: request.version, status: status, headers: headers)
    let connectionHeaders: [String] = head.headers[canonicalForm: "connection"].map { $0.lowercased() }

    if !connectionHeaders.contains("keep-alive") && !connectionHeaders.contains("close") {
        // the user hasn't pre-set either 'keep-alive' or 'close', so we might need to add headers
        switch (request.isKeepAlive, request.version.major, request.version.minor) {
        case (true, 1, 0):
            // HTTP/1.0 and the request has 'Connection: keep-alive', we should mirror that
            head.headers.add(name: "Connection", value: "keep-alive")
        case (false, 1, let n) where n >= 1:
            // HTTP/1.1 (or treated as such) and the request has 'Connection: close', we should mirror that
            head.headers.add(name: "Connection", value: "close")
        default:
            // we should match the default or are dealing with some HTTP that we don't support, let's leave as is
            ()
        }
    }
    return head
}
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        print("I'am the handler")
        let buff = self.unwrapInboundIn(data)
        let str = buff.getString(at: 0, length: buff.readableBytes) ?? "DEFAULT MESSAGE"
        let sourceAddress = context.channel.remoteAddress!
        let sourceIP = sourceAddress.ipAddress
        print("Received string: \(str) from \(sourceIP ?? "UNKNOWN")")
        var outBuff = context.channel.allocator.buffer(capacity: 100)
        outBuff.writeString("OLA")
        context.writeAndFlush(self.wrapOutboundOut(outBuff),promise: nil)
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
        /*
        var buffer = context.channel.allocator.buffer(capacity: 100)
        buffer.writeString("Bienvenido a mi servidor HTTP")
        context.write(self.wrapOutboundOut(.body(.byteBuffer(buffer))), promise: nil)
        context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
        */
    }

    func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: \(error.localizedDescription)")
        context.close(promise: nil)
    }
}