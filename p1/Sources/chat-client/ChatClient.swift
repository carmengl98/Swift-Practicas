//
//  ChatClient.swift
//

import Foundation
import Socket
import ChatMessage

enum ChatClientError: Error {
    case wrongAddress
    case networkError(socketError: Error)
    case protocolError
}

class ChatClient {
    let host: String
    let port: Int
    let nick: String
    
    init(host: String, port: Int, nick: String) {
        self.host = host
        self.port = port
        self.nick = nick
    }
    
    var isReader: Bool { return nick == "reader" }
    
    func run() throws {
        // Your code here
        do{
      
        guard let serverAddress = Socket.createAddress(for: server, on: Int32(self.port)) else {
            throw ChatClientError.wrongAddress
        }
        let clientSocket = try Socket.create(family: .inet, type: .datagram, proto: .udp)
        var buffer = Data(capacity:1024)
        var finish = false

        //ESCRIBIMOS en el BUFFER LOS DATOS A ENVIAR---> CABECERA + DATOS
        try msgInit(socket: clientSocket, address: serverAddress)
        buffer.removeAll()

        if self.isReader{
                
            repeat{

                var offset = 0
                let(_, _) = try clientSocket.readDatagram(into: &buffer)                
                    
                    //LEEMOS LA CABECERA DEL BUFFER QUE NOS LLEGA DEL SEVIDOR
                    let headerServer = buffer.withUnsafeBytes{ pointer in
                        pointer.load(fromByteOffset: offset, as: ChatMessage.self)                        
                    }
                
                    offset += MemoryLayout<ChatMessage>.size 
                    guard headerServer == ChatMessage.Server else{
                        throw ChatClientError.protocolError
                    }
                    //LEEMOS EL NICK DEL BUFFER QUE NOS LLEGA DEL SEVIDOR
                    let nickname = buffer.advanced(by: offset).withUnsafeBytes{ pointer in
                        String(cString: pointer.bindMemory(to: UInt8.self).baseAddress!)
                    }
                    offset += nickname.count + 1
                    //LEEMOS EL MENSAJE DEL BUFFER QUE NOS LLEGA DEL SEVIDOR
                    let str = buffer.advanced(by: offset).withUnsafeBytes{ pointer in
                        String(cString: pointer.bindMemory(to: UInt8.self).baseAddress!)
                    }
                    offset += str.count + 1
                     
                    print ("\(nickname): \(str)")
                    buffer.removeAll()

            }while true
            
        }else{
                
            repeat{

                print("Message: ",terminator: "")
                if let msg = readLine(), msg != ".quit"{
                    //ESCRIBIMOS en el BUFFER LOS DATOS A ENVIAR---> CABECERA + DATOS
                    try msgWriter(socket: clientSocket, address: serverAddress, msg: msg)
                    buffer.removeAll()
                    
                }else {
                    finish = true
                }
            }while !finish 
            clientSocket.close() 
                
        }
        buffer.removeAll() 
            
    }catch let error{
        throw ChatClientError.networkError(socketError: error) 
    }

    }
}
    

// Add additional functions using extensions

extension ChatClient{

    func msgInit(socket:Socket, address: Socket.Address) throws{
        var buffer = Data(capacity:1024)

        //CABECERA DEL MENSAJE (INIT)
        withUnsafeBytes(of: ChatMessage.Init){ pointer in
            buffer.append(contentsOf: pointer)
        }
        //NICKNAME
        self.nick.utf8CString.withUnsafeBytes{ pointer in
            buffer.append(contentsOf: pointer)
        }
        try socket.write(from:buffer, to:address)
    }
        
    func msgWriter(socket: Socket, address: Socket.Address, msg: String) throws{
        var buffer = Data(capacity:1024)
        //CABECERA DEL MENSAJE (WRITER)
        withUnsafeBytes(of: ChatMessage.Writer){ pointer in
            buffer.append(contentsOf: pointer)
        }
        //DATOS
        msg.utf8CString.withUnsafeBytes{ pointer in
            buffer.append(contentsOf: pointer)
        }
        try socket.write(from:buffer, to: address)
    }
    
}