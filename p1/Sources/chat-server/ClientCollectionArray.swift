//
//  ClientCollectionArray.swift
//  Implementation of ClientCollection that uses an array as the backend.
//
import Socket

/// Implements a `ClientCollection` using an Array as the backend
struct ClientCollectionArray {
    struct Client {
        var address: Socket.Address
        var nick: String
    }
    
    private var clients = [Client]()
    let uniqueNicks: Bool

    init(uniqueNicks: Bool = true) {
        self.uniqueNicks = uniqueNicks
    }
}

/// ClientCollection functions have to be implemented here
extension ClientCollectionArray: ClientCollection {
    mutating func addClient(address: Socket.Address, nick: String) throws{
         if uniqueNicks && clients.contains { pointer in
            pointer.nick == nick} {
            
            throw ClientCollectionError.repeatedClient
            
        }
        clients.append(Client(address: address, nick: nick)) 
 
    }

    mutating func removeClient(nick: String) throws{
        for i in 0..<clients.count{
            if clients[i].nick == nick {
                clients.remove(at: i)
            }else{
                throw ClientCollectionError.noSuchClient
            }
        }

    }

    func searchClient(address: Socket.Address) -> String? {
        
        return clients.filter{ client in
            client.address == address}.map{$0.nick}.first
    }  
    
    
    func forEach(_ body: (Socket.Address, String) throws -> Void) rethrows{
        try self.clients.forEach{ try body($0.address, $0.nick)}
    }
    
}

// Add additional extensions if you need to
