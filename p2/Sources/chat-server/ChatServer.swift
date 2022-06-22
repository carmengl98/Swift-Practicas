//
//  ChatServer.swift
//

import Foundation
import Socket
import ChatMessage
import Collections

// Your code here
enum ChatServerError: Error {
    case networkError(socketError: Error)
    case protocolError 
}

class ChatServer {
    let port: Int
    var serverSocket: Socket
    let numNick: Int
    var datagramReader: DatagramReader? = nil

    struct ActiveClient{
        var nick: String
        var address: Socket.Address
        var timestamp: Date
    }
    
    struct OldClient{
        var nick: String
        var timestamp: Date
    }

    var activeClient: ArrayQueue<ActiveClient> 
    var oldClient = ArrayStack<OldClient>()
    
    init(port: Int, numNick: Int) throws {
        self.port = port
        self.numNick = numNick
        self.serverSocket = try Socket.create(family: .inet, type: .datagram, proto: .udp)
        self.activeClient = ArrayQueue<ActiveClient>(maxCapacity: numNick)
    }
        
    func run() throws {
        do{
            try self.serverSocket.listen(on: port)
            
            self.datagramReader = DatagramReader(socket: self.serverSocket, capacity: 1024){(buffer, bytesRead, address) in
                self.handler(buffer:buffer, bytesRead:bytesRead, address: address!)
            }

            let df = DateFormatter()
            df.dateFormat = "dd-MMM-yy HH:mm:ss"
            repeat{
                if let info = readLine(){
                    if info == "L" || info == "l"{
                        print("ACTIVE CLIENTS")
                        print("==============")
                        activeClient.forEach{ activeClient in
                            let(ip,port) = Socket.hostnameAndPort(from: activeClient.address)!
                            print("\(activeClient.nick) \(ip):\(port) \(df.string(from: activeClient.timestamp))")
                        }
                        print()
    
                    }else if info == "O" || info == "o"{
                        print("OLD CLIENTS")
                        print("===========")
                        oldClient.forEach{ oldClient in
                            print("\(oldClient.nick): \(df.string(from: oldClient.timestamp))")
                        }
                        print()
                    }
                }
                
            } while true

        } catch let error {
            throw ChatServerError.networkError(socketError: error)
        }
    }
}

// Add additional functions using extensions
extension ChatServer{
    func handler(buffer: Data, bytesRead: Int, address: Socket.Address){
        do {
            
            var readerBuffer = buffer  
            var writerBuffer = Data(capacity: 1024)

            //LEEMOS LA CABECERA QUE NOS LLEGA DEL CLIENTE
            let headerClient = readerBuffer.withUnsafeBytes{ $0.load(as: ChatMessage.self) }
            
            switch headerClient {
                case .Init:

                    guard headerClient == ChatMessage.Init else{
                        throw ChatServerError.protocolError
                    } 

                    readerBuffer = readerBuffer.advanced(by: MemoryLayout<ChatMessage>.size) 

                    //LEEMOS EL RESTO DEL BUFFER QUE NOS LLEGA DEL CLIENTE
                    let nickname = readerBuffer.withUnsafeBytes{ String(cString: $0.bindMemory(to: UInt8.self).baseAddress!) }
                        
                    readerBuffer.removeAll()
                    print ("INIT received from \(nickname): ",terminator: "")
                
                        let repeated = activeClient.contains { $0.nick == nickname}
                        if !(repeated){  
                            do{
                                let newClient = ActiveClient(nick: nickname, address: address, timestamp: Date())
                                try activeClient.enqueue(newClient)
                            } catch CollectionsError.maxCapacityReached{
                                let bannedClient = activeClient.dequeue()
                                oldClient.push(OldClient(nick: bannedClient!.nick, timestamp: Date()))
                                try! activeClient.enqueue(ActiveClient(nick:nickname, address: address, timestamp: Date()))
            
                                writerBuffer.removeAll()
                                //ESCRIBIMOS en el BUFFER LOS DATOS A ENVIAR---> CABECERA + DATOS
                                //CABECERA DEL MENSAJE (SERVER)
                                withUnsafeBytes(of: ChatMessage.Server){ writerBuffer.append(contentsOf: $0)}
                                "server".utf8CString.withUnsafeBytes{ writerBuffer.append(contentsOf: $0)}
                                let msg = "\(bannedClient!.nick) banned for being idle too long"
                                msg.utf8CString.withUnsafeBytes{ writerBuffer.append(contentsOf: $0)}
                                
                                try activeClient.forEach { activeClient in
                                    if activeClient.nick != nickname{
                                        try serverSocket.write(from: writerBuffer,to: activeClient.address)
                                    } 
                                }
                                
                                try serverSocket.write(from: writerBuffer,to: bannedClient!.address)
                                writerBuffer.removeAll()
                            }

                            print("ACCEPTED")

                            writerBuffer.removeAll() 
                            //ESCRIBIMOS en el BUFFER LOS DATOS A ENVIAR---> CABECERA + DATOS
                            //CABECERA DEL MENSAJE (WELCOME)
                            withUnsafeBytes(of: ChatMessage.Welcome){ writerBuffer.append(contentsOf: $0)}
                            //TRUE
                            withUnsafeBytes(of: true ){ writerBuffer.append(contentsOf: $0)}

                            try serverSocket.write(from: writerBuffer, to: address)
                            writerBuffer.removeAll()
                            
                            //ESCRIBIMOS en el BUFFER LOS DATOS A ENVIAR---> CABECERA + DATOS
                            //CABECERA DEL MENSAJE (SERVER)
                            withUnsafeBytes(of: ChatMessage.Server){ writerBuffer.append(contentsOf: $0)}
                            "server".utf8CString.withUnsafeBytes{ writerBuffer.append(contentsOf: $0)}
                            let msg = "\(nickname) joins the chat"
                            msg.utf8CString.withUnsafeBytes{ writerBuffer.append(contentsOf: $0)}

                            try activeClient.forEach { activeClient in
                                if activeClient.nick != nickname{
                                    try serverSocket.write(from: writerBuffer,to: activeClient.address)
                                } 
                            }
                            writerBuffer.removeAll()
                         
                        }else{
                            print("IGNORED. Nick already used")
                            writerBuffer.removeAll()
                            //ESCRIBIMOS en el BUFFER LOS DATOS A ENVIAR---> CABECERA + DATOS
                            //CABECERA DEL MENSAJE (WELCOME)
                            withUnsafeBytes(of: ChatMessage.Welcome){ writerBuffer.append(contentsOf: $0)}
                            //FALSE
                            withUnsafeBytes(of: false ){ writerBuffer.append(contentsOf: $0)}
                            
                            try serverSocket.write(from: writerBuffer, to: address)  
                            writerBuffer.removeAll()
                        }
                    
                case .Writer:

                    readerBuffer = readerBuffer.advanced(by: MemoryLayout<ChatMessage>.size) 
                        
                    //LEEMOS el BUFFER
                    let nickname = readerBuffer.withUnsafeBytes{ String(cString: $0.bindMemory(to: UInt8.self).baseAddress!)}
                    
                    readerBuffer = readerBuffer.advanced(by: nickname.utf8.count + 1)
                    let msg = readerBuffer.withUnsafeBytes{ String(cString: $0.bindMemory(to: UInt8.self).baseAddress!) }
                     
                    readerBuffer.removeAll()
                    print ("WRITER received from ",terminator: "")
          
                    var existClient = activeClient.findFirst {$0.nick == nickname && $0.address == address} 
                    if existClient != nil {
                        print ("\(nickname): \(msg)")

                        activeClient.remove{ $0.nick == nickname}
                        
                        existClient!.timestamp = Date() 
                        try! self.activeClient.enqueue(existClient!)
                        
                        writerBuffer.removeAll()
                        //ESCRIBIMOS en el BUFFER LOS DATOS A ENVIAR---> CABECERA + DATOS
                        //CABECERA DEL MENSAJE (SERVER)
                        withUnsafeBytes(of: ChatMessage.Server){ writerBuffer.append(contentsOf: $0)}
                        //NICKNAME    
                        nickname.utf8CString.withUnsafeBytes{ writerBuffer.append(contentsOf: $0)}
                        //msg
                        msg.utf8CString.withUnsafeBytes{ writerBuffer.append(contentsOf: $0)}
                            
                       try activeClient.forEach { activeClient in
                            if activeClient.nick != nickname{
                                try serverSocket.write(from: writerBuffer,to: activeClient.address)
                            } 
                        }
                        writerBuffer.removeAll()
                    } else{
                        print("unknown client. IGNORED")
                    }
                        
                case .Logout:

                    readerBuffer = readerBuffer.advanced(by: MemoryLayout<ChatMessage>.size) 
                    
                    //LEEMOS el BUFFER
                    let nickname = readerBuffer.withUnsafeBytes{ String(cString: $0.bindMemory(to: UInt8.self).baseAddress!)}
                    
                    readerBuffer.removeAll()
                    print ("LOGOUT received from ",terminator: "")

                    let existClient = activeClient.findFirst{ $0.nick == nickname && $0.address == address}
                    if existClient != nil {
                        
                        activeClient.remove{ $0.nick == nickname }
                        oldClient.push(OldClient(nick: nickname, timestamp: Date()))
                        print(nickname)

                        writerBuffer.removeAll()
                        //ESCRIBIMOS en el BUFFER LOS DATOS A ENVIAR---> CABECERA + DATOS
                        //CABECERA DEL MENSAJE (SERVER)
                        withUnsafeBytes(of: ChatMessage.Server){ writerBuffer.append(contentsOf: $0)}
                        //msg
                        "server".utf8CString.withUnsafeBytes{ writerBuffer.append(contentsOf: $0)}
                        let msg = "\(nickname) leaves the chat"
                        msg.utf8CString.withUnsafeBytes{ writerBuffer.append(contentsOf: $0)}
                        try activeClient.forEach { activeClient in
                            if activeClient.nick != nickname{
                                try serverSocket.write(from: writerBuffer,to: activeClient.address)
                            } 
                        }
                        writerBuffer.removeAll()
                            
                    }else{
                        print("unknown client. IGNORED")  
                    }
                    
                default: 
                    throw ChatServerError.protocolError
                }  
        } catch let error {
            //throw ChatServerError.networkError(socketError: error)
            print(error)
        }
    }

}