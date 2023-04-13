import NIO
import Foundation
import NIOHTTP1
import Backtrace
import Lifecycle
import Logging

class Handler:ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart
    let logger = Logger(label: "SubSystemLifecycle")
    let componentlifecycle: ComponentLifecycle = ComponentLifecycle(label: "SubSystem")
    let router:Router = Router()
    var isStarted = false
    var pendingProcess = false
    var context:ChannelHandlerContext? = nil  // esta bien ?  

    init(_ lifecycle: inout ServiceLifecycle) {
        lifecycle.register(self.componentlifecycle)
        componentlifecycle.start { error in       
            if let error = error {
                print("Lifecycle failed starting  ☠️: \(error)")
            } else {
                print("Lifecycle started successfully 🚀")
                self.isStarted = true
                if self.router.requestExists() && self.pendingProcess == true && self.context != nil { 
                   self.move(context:self.context!) 
                }
            }
        }
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        print("I'am the channelRead")
        router.setRequest(self.unwrapInboundIn(data))
        self.context = context
        if self.router.requestExists() && isStarted {
            move(context: context)
            self.isStarted = false
        }
        else {
            pendingProcess = true
        }
    }

    func move(context: ChannelHandlerContext){
        let html = router.move(context: context)
        let responseHeaders = HTTPHeaders([("content-type", "text/html")])
        let responseData = context.channel.allocator.buffer(string: html)
        let responseHead = HTTPResponseHead(version: .init(major: 1, minor: 1), status: .ok, headers: responseHeaders)
        let responsePartHead = HTTPServerResponsePart.head(responseHead)
        context.write(self.wrapOutboundOut(responsePartHead), promise: nil)
        let responsePartBody = HTTPServerResponsePart.body(.byteBuffer(responseData))
        context.write(self.wrapOutboundOut(responsePartBody), promise: nil)
        let responsePartEnd = HTTPServerResponsePart.end(nil)
        context.writeAndFlush(self.wrapOutboundOut(responsePartEnd), promise: nil)
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


