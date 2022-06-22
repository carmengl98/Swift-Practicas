public struct ArrayQueue<Element> : Queue {
    private var storage = [Element]()

    public var count: Int { return storage.count }
    public var maxCapacity: Int 

    public init(maxCapacity:Int){
        self.maxCapacity = maxCapacity
    } 

    public mutating func enqueue(_ value: Element) throws {
        guard storage.count != maxCapacity else{
            throw CollectionsError.maxCapacityReached
        }
        return storage.append(value)
    }
    
    public mutating func dequeue() -> Element? {
        guard storage.count > 0 else {
            return nil
        }
        return storage.removeFirst()
    }
    
    public func forEach(_ body: (Element) throws -> Void) rethrows {
        try storage.forEach{ try body($0)}
    }
    
    public func contains(where predicate: (Element) -> Bool) -> Bool{
        return storage.contains(where: predicate)
    }

    public func findFirst(where predicate: (Element) -> Bool) -> Element?{
        return storage.first(where: predicate)
    }
    
    public mutating func remove(where predicate: (Element) -> Bool){
        return storage.removeAll(where: predicate)
    }

}

