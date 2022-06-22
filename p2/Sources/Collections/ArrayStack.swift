public struct ArrayStack<Element> : Stack {
    private var storage = [Element]()  
    
    public init(){}  

    public mutating func push(_ value: Element){
        return storage.insert(value, at: 0)
    }
    
    public mutating func pop() -> Element?{
        guard storage.count > 0 else{
            return nil
        }
        return storage.remove(at: 0)
    }
    
    public func forEach(_ body: (Element) throws -> Void) rethrows{
       try self.storage.forEach{ try body($0)}

    }
    
}