import Foundation

// Read command-line argumens
let arguments = Array(CommandLine.arguments[1...])
guard arguments.count == 3, let port = Int(arguments[1]) else {
    print("Error")
    exit(1)
}   

let server = arguments[0]
let nickname = arguments[2]

// Create ChatClient
let chatClient = ChatClient(host: server, port: port, nick: nickname)

// Run ChatClient
do{
    try chatClient.run()
} catch let error{
    print(error)
}
