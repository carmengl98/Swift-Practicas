import Foundation

//Read command-line arguments
let arguments = Array(CommandLine.arguments[1...])
guard arguments.count == 1,let port = Int(arguments[0]) else {
    print("Error")
    exit(1)
}   


// Run ChatServer
do{
    // Create ChatServer
    let chatServer = try ChatServer(port: port)
    try chatServer.run()
}catch let error{
    print(error)
}