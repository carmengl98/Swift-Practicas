//
//  ChatServer.swift
//

import Foundation
import Socket
import ChatMessage

enum ChatServerError: Error {
    /**
     Thrown on communications error.
     Initialize with the underlying Error thrown by the Socket library.
     */
    case networkError(socketError: Error)
    
    /**
     Thrown if an unexpected message or argument is received.
     For example, the server should never receive a 'Server' message.
     */
    case protocolError
}

class ChatServer {
    let port: Int
    var serverSocket: Socket
    
    var readers = ClientCollectionArray(uniqueNicks: false)
    var writers = ClientCollectionArray(uniqueNicks: true)
    
    init(port: Int) throws {
        self.port = port
        serverSocket = try Socket.create(family: .inet, type: .datagram, proto: .udp)
    }
    
    func run() throws {
        do {
            // Your code here
            try serverSocket.listen(on: port)
            var buffer = Data(capacity: 1024)
        
            repeat{
                let (_, clientAddress) = try serverSocket.readDatagram(into: &buffer)
                if let address = clientAddress {                    
                    var offset = 0
                    
                    //LEEMOS LA CABECERA DEL BUFFER QUE NOS LLEGA DEL CLIENTE
                    let headerClient = buffer.withUnsafeBytes{ pointer in
                        pointer.load(fromByteOffset: offset, as: ChatMessage.self)                
                    }
                    offset += MemoryLayout<ChatMessage>.size 

                    switch headerClient {
                    case .Init:
                        
                        //LEEMOS EL RESTO DEL BUFFER QUE NOS LLEGA DEL CLIENTE
                        let nickname = buffer.advanced(by: offset).withUnsafeBytes{ pointer in
                            String(cString: pointer.bindMemory(to: UInt8.self).baseAddress!)
                        }
                        
                        offset += nickname.count + 1
                        
                        buffer.removeAll()
                        print ("INIT received from \(nickname)",terminator: "")

                       if nickname == "reader"{
                            
                            try! self.readers.addClient(address: address, nick: nickname)
                            print("")

                        }else{
                            do{
                            
                                try self.writers.addClient(address: address, nick: nickname)
                                print("")
            
                                buffer.removeAll()
                            
                                //ESCRIBIMOS en el BUFFER CON LOS DATOS A ENVIAR---> CABECERA + DATOS
                                try msgServerJoins(nick: nickname, socket: serverSocket, address: address)
                              
                                buffer.removeAll()
                    
                            }catch ClientCollectionError.repeatedClient {
                                print(" .IGNORED, nick already used")
                            }
                            
                        }
                    
                    case .Writer:
                        
                        //LEEMOS el BUFFER
                        let str = buffer.advanced(by: offset).withUnsafeBytes{ pointer in
                            String(cString: pointer.bindMemory(to: UInt8.self).baseAddress!)
                        }
                     
                        buffer.removeAll()
                        
                        print ("WRITER received from ",terminator: "")
                        if let nickname = self.writers.searchClient(address: address){
                        //ESCRIBIMOS en el BUFFER CON LOS DATOS A ENVIAR---> CABECERA + DATOS
                        try msgServer(nick: nickname, str: str, socket: serverSocket, address: address)

                            print ("\(nickname): \(str)")

                            buffer.removeAll()
                        } else{
                            print("unknown client. IGNORED")
                        }
                        

                    default: 
                        throw ChatServerError.protocolError
                    }  
                } else{
                    print("ERROR")
                }
                buffer.removeAll()

            }while true

         } catch let error {
            throw ChatServerError.networkError(socketError: error)
        }
    }
}
       

// Add additional functions using extensions

extension ChatServer{

    func msgServer(nick: String, str: String ,socket:Socket, address: Socket.Address) throws{
        var buffer = Data(capacity:1024)

        //CABECERA DEL MENSAJE (SERVER)
        withUnsafeBytes(of: ChatMessage.Server){ pointer in
            buffer.append(contentsOf: pointer)
        }
        //NICKNAME
        nick.utf8CString.withUnsafeBytes{ pointer in
            buffer.append(contentsOf: pointer)
        }
        str.utf8CString.withUnsafeBytes{ pointer in
            buffer.append(contentsOf: pointer)
        }
        try self.readers.forEach {(address, nick) in
            try socket.write(from: buffer,to: address)
        }
    }

    func msgServerJoins(nick: String, socket:Socket, address: Socket.Address) throws{
        var buffer = Data(capacity:1024)
        //CABECERA DEL MENSAJE (SERVER)
        withUnsafeBytes(of: ChatMessage.Server){ pointer in
            buffer.append(contentsOf: pointer)
        }
        //Server
        "server".utf8CString.withUnsafeBytes{ pointer in
            buffer.append(contentsOf: pointer)
        }
        let msg = "\(nick) joins to the chat"
        msg.utf8CString.withUnsafeBytes{ pointer in
            buffer.append(contentsOf: pointer)
        }
                                
        try self.readers.forEach {(address, nickname) in
            try serverSocket.write(from: buffer,to: address)
        }
    }
}