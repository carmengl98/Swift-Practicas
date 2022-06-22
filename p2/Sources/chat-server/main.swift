import Foundation

// Read command-line arguments
let arguments = Array(CommandLine.arguments[1...])
guard arguments.count == 2, let port = Int(arguments[0]), let numClient = Int(arguments[1]), (numClient >= 2 && numClient <= 50)else{
    print("usage: \(CommandLine.arguments[0]) <port> <max_clients>")
    exit(1)
}


// Run ChatServer
do{
    // Create ChatServer
let chatServer = try ChatServer(port: port, numNick: numClient)
    try chatServer.run()
} catch{
    print(error)
}