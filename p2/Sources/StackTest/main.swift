import Collections

func processAll<S: Stack>(testStack: inout S) {
    var item: S.Element?
    repeat {
        item = testStack.pop()
        if item != nil {
            print(item!)
        }
    } while item != nil
}

var testStack = ArrayStack<Int>()
    
print()
    
testStack.push(1)
testStack.push(2)
testStack.push(3)
testStack.push(4)

print()
print("Items of the testQueue:")
testStack.forEach{print($0)}
    

print()
print("Process all: ")
processAll(testStack: &testStack)

print()
print("Items of the testQueue:")
testStack.forEach{print($0)}
    
