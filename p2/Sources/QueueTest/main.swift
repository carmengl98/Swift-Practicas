import Collections

    var testQueue = ArrayQueue<Int>(maxCapacity: 4)
    if testQueue.count == 0{ print("The queue is empty.")}
    print()
    do{
        try testQueue.enqueue(1)
        try testQueue.enqueue(2)
        try testQueue.enqueue(3)
        try testQueue.enqueue(4)
        try testQueue.enqueue(5)
    }catch CollectionsError.maxCapacityReached{
        print("ERROR: max capacity reached")
    }

    print()
    print("Items of the testQueue:")
    testQueue.forEach{print($0)}
    
    print()
    print("testQueue contains 1: \(testQueue.contains{ $0 == 1})")
    print("testQueue contains 4: \(testQueue.contains{ $0 == 4})")
    print("testQueue contains 5: \(testQueue.contains{ $0 == 5})")
    print("testQueue contains 7: \(testQueue.contains{ $0 == 7})")

    print()
    let item = testQueue.findFirst{ $0 % 2 == 0}
    if let item = item {
        print("findFirst: \(item)")
    }
    
    testQueue.remove {$0 % 2 == 0}

    print()
    print("Remove 1 using dequeue.")
    testQueue.dequeue()  //1
    
    print()
    print("Items of the testQueue:")
    testQueue.forEach{print($0)}

    


