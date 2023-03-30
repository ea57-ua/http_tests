import NIO
import NIOHTTP1
import Foundation
import Backtrace
import Lifecycle
import LifecycleNIOCompat
import Logging

class http_server_test{
    private let group: MultiThreadedEventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    private var server: ServerBootstrap
    private let host = "127.0.0.1"
    private let port = 8080
    private var channel:Channel!
    //var lifecycle : ServiceLifecycle

    init() {
        let lc: ServiceLifecycle = ServiceLifecycle(configuration: ServiceLifecycle.Configuration(label: "http", installBacktrace: true))
    
        server = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)

        server        
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline().flatMap {
                    channel.pipeline.addHandlers([Handler(lc)])
                } 
            }        
            .childChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
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

