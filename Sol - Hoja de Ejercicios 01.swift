func occurrences(list: [String], s: String) -> Int {
    var total = 0
    
    for element in list {
        if element == s {
            total += 1
        }
    }
    
    return total
}

print(occurrences(list: ["1", "1", "1"], s: "1")) // 3
print(occurrences(list: ["1", "2", "3"], s: "2")) // 1
print(occurrences(list: [], s: "3")) // 0
print(occurrences(list: ["1", "2", "3"], s: "5")) // 0

func occurrences(list: [String], s: String) -> Int {
    return list.reduce(0){ (acc, elem) in
        if elem == s {
            return acc + 1
        } else {
            return acc
        }
    }
}

print(occurrences(list: ["1", "1", "1"], s: "1")) // 3
print(occurrences(list: ["1", "2", "3"], s: "2")) // 1
print(occurrences(list: [], s: "3")) // 0
print(occurrences(list: ["1", "2", "3"], s: "5")) // 0

func occurrences(list: [String], s: String) -> Int {
    if let head = list.first {
        let tail = Array(list.dropFirst())
        if head == s {
            return 1 + occurrences(list: tail, s: s)
        } else {
            return occurrences(list: tail, s: s)
        }
    } else {
        return 0
    }
}

print(occurrences(list: ["1", "1", "1"], s: "1")) // 3
print(occurrences(list: ["1", "2", "3"], s: "2")) // 1
print(occurrences(list: [], s: "3")) // 0
print(occurrences(list: ["1", "2", "3"], s: "5")) // 0

func occurrences(list: [String], s: String) -> Int {
    func occurrencesAux(_ list: [String], _ acc: Int) -> Int {
        if let head = list.first {
            let tail = Array(list.dropFirst())
            if head == s {
                return occurrencesAux(tail, acc + 1)
            } else {
                return occurrencesAux(tail, acc)
            }
        } else {
            return acc
        }
    }
    
    return occurrencesAux(list, 0)
}

print(occurrences(list: ["1", "1", "1"], s: "1")) // 3
print(occurrences(list: ["1", "2", "3"], s: "2")) // 1
print(occurrences(list: [], s: "3")) // 0
print(occurrences(list: ["1", "2", "3"], s: "5")) // 0

func drop(list: [Bool], n: Int) -> [Bool] {
    if n >= 1 {
        if n <= list.count {
            return Array(list[n...])
        } else {
            return []
        }
    } else {
        return list
    }
}

print(drop(list: [true, false], n: 0)) // [true, false]
print(drop(list: [true, false, false, true], n: 2)) // [false, true]
print(drop(list: [true, false, true, true, false, true], n: 3)) // [true, false, true]
print(drop(list: [Bool](), n: 0)) // []
print(drop(list: [true, false, true, true, false, true], n: 6)) // []
print(drop(list: [Bool](), n: 2)) // []
print(drop(list: [true, false, true, true, false, true], n: 8)) // []

func partitionOddEven(list: [Int]) -> ([Int], [Int]) {
    return list.reduce(([Int](), [Int]())){ (acc, elem) in
        let (odds, evens) = acc
        if elem % 2 != 0 {
            return (odds + [elem], evens)
        } else {
            return (odds, evens + [elem])
        }
    }
}

print(partitionOddEven(list: [])) // ([], [])
print(partitionOddEven(list: [1, 3, 5])) //([1, 3, 5], [])
print(partitionOddEven(list: [0, 2, 4, 6])) // ([], [0, 2, 4, 6])
print(partitionOddEven(list: [1, 2, 3, 4, 5])) // ([1, 3, 5], [2, 4])

func sum(list: [(Int, Int)]) -> [Int] {
    if let head = list.first {
        let tail = Array(list.dropFirst())
        return [head.0 + head.1] + sum(list: tail)
    } else {
        return []
    }
}

print(sum(list: [])) // []
print(sum(list: [(0, 0)])) // [0]
print(sum(list: [(1, 2), (3, 4), (5, 6)])) // [3, 7, 11]

func sum(list: [(Int, Int)]) -> [Int] {
    return list.map{ tuple in
        tuple.0 + tuple.1 // return tuple.0 + tuple.1
    }
}

print(sum(list: [])) // []
print(sum(list: [(0, 0)])) // [0]
print(sum(list: [(1, 2), (3, 4), (5, 6)])) // [3, 7, 11]

func sum(list: [(Int, Int)]) -> [Int] {
    func sumAux(_ list: [(Int, Int)], _ acc: [Int]) -> [Int] {
        if let head = list.first {
            let tail = Array(list.dropFirst())
            return sumAux(tail, acc + [head.0 + head.1])
        } else {
            return acc
        }
    }
    
    return sumAux(list, [])
}

print(sum(list: [])) // []
print(sum(list: [(0, 0)])) // [0]
print(sum(list: [(1, 2), (3, 4), (5, 6)])) // [3, 7, 11]

func minMax(list: [Int]) -> (min: Int, max: Int)? {
    if let head = list.first {
        var min = head
        var max = head
        
        for elem in list.dropFirst() {
            if elem < min {
                min = elem
            } else if elem > max {
                max = elem
            }
        }
        return (min, max)
    }
    return nil
}

print(minMax(list: [])) // nil
print(minMax(list: [1, 1, 1, 1, 1])) // Optional((min: 1, max: 1))
print(minMax(list: [-5, 2, 1, 0, 10, -15, 50])) // Optional((min: -15, max: 50))

func vowels(s: String) -> (once: Int, twice: Int, moreThanTwice: Int) {
    var once = Set<Character>()
    var twice = Set<Character>()
    var moreThanTwice = Set<Character>()
    
    let vowels = Set<Character>(["a", "e", "i", "o", "u"])
    for c in s.lowercased() {
        if vowels.contains(c) {
            if !moreThanTwice.contains(c) {
                if twice.contains(c) {
                    twice.remove(c)
                    moreThanTwice.insert(c)
                } else if once.contains(c) {
                    once.remove(c)
                    twice.insert(c)
                } else {
                    once.insert(c)
                }
            }
        }
    }
    
    return (once: once.count, twice: twice.count, moreThanTwice: moreThanTwice.count)
}

print(vowels(s: "a,e EpoOluaMn'=ai")) // (once: 2, twice: 2, moreThanTwice: 1)

func charactersCounter(s: String) -> [Character: Int] {
    var result = [Character: Int]()
    for c in s {
        result[c, default: 0] += 1
    }
    return result
}

print(charactersCounter(s: "En un lugar de La Mancha, de cuyo nombre no quiero acordarme...")) // ["d": 3, "n": 5, "a": 6, " ": 11, "r": 5, "b": 1, "q": 1, ",": 1, "y": 1, ".": 3, "c": 3, "o": 5, "l": 1, "L": 1, "m": 2, "h": 1, "E": 1, "u": 4, "i": 1, "M": 1, "e": 5, "g": 1]

func scrabbleScore(word: String, lettersScore: [Character: Int]) -> Int {
    let lettersCounter = charactersCounter(s: word)
    
    var total = 0
    for letter in word {
        if let score = lettersScore[letter] {
            total += score * (lettersCounter[letter] ?? 0)
        }
    }
    
    return total
}

let lettersScore: [Character: Int] = ["a": 1, "b": 3, "c": 3, "d": 2, "e": 1, "f": 4, "g": 2, "h": 4, "i": 1, "j": 8, "k": 5, "l": 1, "m": 3, "n": 1, "o": 1, "p": 3, "q": 10, "r": 1, "s": 1, "t": 1, "u": 1, "v": 8, "w": 4, "x": 8, "y": 4, "z": 10]
print(scrabbleScore(word: "en un lugar de la mancha, de cuyo nombre no quiero acordarme...", lettersScore: lettersScore))
