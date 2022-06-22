//
//  ChatClient.swift
//

import Foundation
import Socket
import ChatMessage
import Dispatch
import Glibc

enum ChatClientError: Error {
    case wrongAddress
    case networkError(socketError: Error)
    case protocolError
    case timeout        
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
        
    func run() throws {
        // Your code here
        do{
            guard let serverAddress = Socket.createAddress(for: self.host, on: Int32(self.port)) else {
                throw ChatClientError.wrongAddress
            }
            let clientSocket = try Socket.create(family: .inet, type: .datagram, proto: .udp)
            try clientSocket.setReadTimeout(value: 10 * 1000)

            var writerBuffer = Data(capacity:1024)
            var readerBuffer = Data(capacity:1024)
            var finish = false

            //ESCRIBIMOS en el BUFFER LOS DATOS A ENVIAR---> CABECERA + DATOS
            //CABECERA DEL MENSAJE (INIT)
            withUnsafeBytes(of: ChatMessage.Init){ writerBuffer.append(contentsOf: $0)}
            //NICK 
            self.nick.utf8CString.withUnsafeBytes{ writerBuffer.append(contentsOf: $0)}

            try clientSocket.write(from: writerBuffer, to:serverAddress)
            writerBuffer.removeAll()
            
            let (bytesRead,_) = try clientSocket.readDatagram(into: &readerBuffer)
                if bytesRead == 0 && errno == EAGAIN {
                    print("Server unreachable")
                }else{

                
                    //LEEMOS LA CABECERA QUE NOS LLEGA DEL SEVIDOR
                    let headerServer = readerBuffer.withUnsafeBytes{ $0.load(as: ChatMessage.self)}
                    readerBuffer = readerBuffer.advanced(by: MemoryLayout<ChatMessage>.size)
                
                    switch headerServer{
                        case .Welcome:
                            guard headerServer == ChatMessage.Welcome else{
                                throw ChatClientError.protocolError
                            }
                        
                            //COMPROBAMOS SI ACCEPTED ES TRUE O FALSE 
                            let accepted = readerBuffer.withUnsafeBytes{ $0.load( as: Bool.self) }
                           
                            if !accepted {
                                print("Mini-Chat v2.0: IGNORED new user \(self.nick), nick already used")
                            }else{
                                print("Mini-Chat v2.0: Welcome \(self.nick)")
                            }
                        
                            //Encargo al handler que lea el datagrama server
                            let _ = DatagramReader(socket: clientSocket, capacity: 1024){(buffer, byteRead, address) in
                                self.handlerReader(buffer: buffer, bytesRead: bytesRead, address: address!,clientSocket: clientSocket)
                            }
                    
                            repeat{
                            
                                print(">> ",terminator: "")
                                if let msg = readLine(), msg != ".quit"{
                                    writerBuffer.removeAll()
                                    //ESCRIBIMOS en el BUFFER LOS DATOS A ENVIAR---> CABECERA + DATOS
                                    //CABECERA DEL MENSAJE (WRITER)
                                    withUnsafeBytes(of: ChatMessage.Writer){ writerBuffer.append(contentsOf: $0)}
                                    //NICK 
                                    self.nick.utf8CString.withUnsafeBytes{ writerBuffer.append(contentsOf: $0)}
                                    //DATOS
                                    msg.utf8CString.withUnsafeBytes{ writerBuffer.append(contentsOf: $0)}

                                    try clientSocket.write(from: writerBuffer, to:serverAddress)
                                    writerBuffer.removeAll()
                    
                                }else {
                                    finish = true
                                }
                            }while !finish 

                            writerBuffer.removeAll()
                            //ESCRIBIMOS en el BUFFER LOS DATOS A ENVIAR---> CABECERA + DATOS
                            //CABECERA DEL MENSAJE (LOGOUT)
                            withUnsafeBytes(of: ChatMessage.Logout){ writerBuffer.append(contentsOf: $0)}
                            //NICK
                            self.nick.utf8CString.withUnsafeBytes{ writerBuffer.append(contentsOf: $0)}

                            try clientSocket.write(from: writerBuffer, to:serverAddress)
                            writerBuffer.removeAll()
                       
                        default:
                            throw ChatClientError.protocolError
                        }
                    }
        } catch let error{
            throw ChatClientError.networkError(socketError: error) 
        }
    }
}

// Add additional functions using extensions
extension ChatClient {
    func handlerReader(buffer: Data, bytesRead: Int, address: Socket.Address, clientSocket: Socket){
        var readerBuffer = buffer 
        
        //LEEMOS LA CABECERA QUE NOS LLEGA DEL SEVIDOR
        let headerServer = readerBuffer.withUnsafeBytes{ $0.load(as: ChatMessage.self)}
        readerBuffer = readerBuffer.advanced(by: MemoryLayout<ChatMessage>.size)
        
        guard headerServer == ChatMessage.Server else{   
            return
        } 
        
        //LEEMOS EL NICK DEL BUFFER QUE NOS LLEGA DEL SEVIDOR
        let nickname = readerBuffer.withUnsafeBytes{ String(cString: $0.bindMemory(to: UInt8.self).baseAddress!)}
        readerBuffer = readerBuffer.advanced(by: nickname.utf8.count + 1)
        
        //LEEMOS EL MENSAJE DEL BUFFER QUE NOS LLEGA DEL SEVIDOR
        let msg = readerBuffer.withUnsafeBytes{ String(cString: $0.bindMemory(to: UInt8.self).baseAddress!)}
        
        print()
        print ("\(nickname): \(msg)")
        readerBuffer.removeAll()
        print(">> ",terminator: "")
        fflush(stdout)
    }
    
}