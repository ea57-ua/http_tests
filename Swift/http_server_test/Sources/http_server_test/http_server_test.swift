import NIO
import NIOHTTP1
import Foundation
import Backtrace
import Lifecycle
import LifecycleNIOCompat
import Logging

class http_server_test{
    let lifecycle = ServiceLifecycle()
    private let group: MultiThreadedEventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    
    private var server: ServerBootstrap
    private let host = "127.0.0.1"
    private let port = 8080
    private var channel:Channel!
    let logger = Logger(label: "Lifecycle")
    
    init() {
        server = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline().flatMap {
                    channel.pipeline.addHandlers([Handler()])
                }
            } 
            /*.childChannelInitializer{ channel in 
                channel.pipeline.addHandler(Handler())
            }*/
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
            .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())
    }

    public func start() {
        print("Starting HTTP server...")
        do {
            channel = try server.bind(host: host, port: port).wait() 
            print("Server started and listening on \(channel.localAddress!)")
            try channel.closeFuture.wait()
        } catch  {
            print("ERROR")
        }
        lifecycle.registerShutdown(
            label: "group", 
            .sync (group.syncShutdownGracefully)
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
    }

    public func stop() {
        do {
            try group.syncShutdownGracefully()
            print("Server closed") 
        } catch {
            print("ERROR")
        }

    }
} 







