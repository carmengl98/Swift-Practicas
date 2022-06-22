import Foundation

// Read command-line arguments
let arguments = Array(CommandLine.arguments[1...])
guard arguments.count == 3, let port = Int(arguments[1]), arguments[2] != "server" else{
    print("usage: \(CommandLine.arguments[0]) <host> <port> <nick>")
    exit(1)
} 
let server = arguments[0]
let nickClient = arguments[2]

// Create ChatClient
let chatClient = ChatClient(host: server, port: port, nick: nickClient)

// Run ChatClient
do{
    try chatClient.run()
}catch let error{
    print(error)
}