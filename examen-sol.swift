struct Rational {
    var numerator: Int
    var denominator: Int
}

let oneThird = Rational(numerator: 1, denominator: 3)
print(oneThird)

extension Rational {
    init(_ numerator: Int, _ denominator: Int) {
        self.init(numerator: numerator, denominator: denominator)
    }
}

let twoThirds = Rational(2, 3)
print(twoThirds)

// Introduce tu código aquí. Puedes utilizar todas las celdas que necesites.
extension Rational: CustomStringConvertible {
    public var description: String {
        "\(self.numerator)/\(self.denominator)"
    }
}

func testDescription(_ rational: Rational, _ expected: String) {
    if rational.description != expected {
        print("Error: tu implementación muestra \(rational.description) pero el mensaje esperado era \(expected)")
    }
}

testDescription(Rational(2, 3), "2/3")
testDescription(Rational(9, 8), "9/8")

// Introduce aquí tu código
extension Rational {
    var value: Double {
        Double(self.numerator) / Double(self.denominator)
    }
}

func testValue(_ rational: Rational, _ expected: Double) {
    if rational.value != expected {
        print("Error, el valor esperado es \(expected), pero tu implementación devuelve: \(rational.value)")
    }
}

testValue(Rational(2, 3), 2/3)
testValue(Rational(9, 8), 9/8)

// Introduce aquí tu código
extension Rational {
    func multiplied(by: Rational) -> Rational {
        return Rational(self.numerator * by.numerator, self.denominator * by.denominator)
    }
}

// Multiplica 1/3 x 1/2
var oneThird = Rational(1, 3)
var half = Rational(1, 2)
var multiplied = oneThird.multiplied(by: half)

// El resultado debe ser 1/6
if multiplied.value != 1/6 {
    print("Error, parece que la multiplicación no ha dado el resultado esperado")
}

// Los factores no han de verse modificados
if oneThird.value != 1/3 {
    print("Error, la multiplicación debe implementarse como una operación inmutable")
}

func testMul(_ one: Rational, _ other: Rational, _ expected: Double) {
    let multiplied = one.multiplied(by: other)
    testValue(multiplied, expected)
}

// 2/3 * 3/2 -> 1
testMul(Rational(2, 3), Rational(3, 2), 1)

// 1/3 * 1/2 -> 1/6
testMul(Rational(1, 3), Rational(1, 2), 1/6)

// 2/3 * 1/2 -> 1/3
testMul(Rational(2, 3), Rational(1, 2), 1/3)

// 2/3 * 3/5 -> 2/5
testMul(Rational(2, 3), Rational(3, 5), 2/5)

func gcd(_ a: Int, _ b: Int) -> Int {
    // Consider positive numbers
    let pa = abs(a)
    let pb = abs(b)
    
    if pa == 0 { return pb }
    if pb == 0 { return pa }
    
    return gcd(abs(pa - pb), min(pa, pb))
}

print(gcd(9, 6))

print(gcd(30, 75))

print(gcd(-30, 75))

// Introduce aquí tu código
extension Rational {
    mutating func simplify() {
        let mcd = gcd(self.numerator, self.denominator)
        self.numerator /= mcd
        self.denominator /= mcd
    }
}

var x = Rational(-30, 75)
x.simplify()
print(x)

func testSimplify(number: Rational, expected: Rational) {
    var simplified = number
    simplified.simplify()
    
    if simplified.value != number.value {
        print("Error: la simplificación da un valor diferente")
    }
    if simplified.numerator != expected.numerator {
        print("Error: se esperaba simplificar \(number) a \(expected), pero el numerador calculado por tu función es \(simplified.numerator)")
    }
    if simplified.denominator != expected.denominator {
        print("Error: se esperaba simplificar \(number) a \(expected), pero el denominador calculado por tu función es \(simplified.denominator)")
    }
}

testSimplify(number: Rational(-30, 75), expected: Rational(-2, 5))
testSimplify(number: Rational(2, 4), expected: Rational(1, 2))

// Introduce aquí tu código
func lcm(_ a: Int, _ b: Int) -> Int {
    return abs(a * b) / gcd(a, b)
}


func testLCM(_ a: Int, _ b: Int, expected: Int) {
    let mcm = lcm(a, b)
    if mcm != expected {
        print("Error: se esperaba que el m.c.m. de \(a) y \(b) sería \(expected), pero tu cálculo devuelve \(mcm)")
    }
}

testLCM(2, 4, expected: 4)
testLCM(2, 3, expected: 6)
testLCM(6, 10, expected: 30)

// Introduce aquí tu código
func add(_ r1: Rational, _ r2: Rational) -> Rational {
    let numerator = 
        r1.numerator * (lcm(r1.denominator, r2.denominator) / r1.denominator) + 
        r2.numerator * (lcm(r1.denominator, r2.denominator) / r2.denominator)
    let denominator = lcm(r1.denominator, r2.denominator)
    return Rational(numerator, denominator)
}

print(add(Rational(1, 2), Rational(1, 3)))

print(add(Rational(1, 2), Rational(-1, 3)))

func testSum(_ n: Rational, _ m: Rational, expected: Rational) {
    let sum = add(n, m)
    if sum.numerator != expected.numerator {
        print("Error: la suma de \(n) y \(m) debería dar \(expected), pero tu resultado es \(sum)")
    }
    if sum.denominator != expected.denominator {
        print("Error: la suma de \(n) y \(m) debería dar \(expected), pero tu resultado es \(sum)")
    }
}

testSum(Rational(1, 2), Rational(1, 3),  expected: Rational(5, 6))
testSum(Rational(1, 2), Rational(-1, 3), expected: Rational(1, 6))
testSum(Rational(1, 3), Rational(1, 4),  expected: Rational(7, 12))
testSum(Rational(2, 3), Rational(4, 5),  expected: Rational(22, 15))

enum Hand {
    case piedra
    case papel
    case tijera
}

// Introduce aquí tu código
extension Hand: CustomStringConvertible {
    public var description: String {
        switch(self) {
            case .piedra: return "👊"
            case .papel: return "✋"
            case .tijera: return "✌️"
        }
    }
}


let player = Hand.papel
let opponent = Hand.tijera
print("\(player) vs \(opponent)")

// Introduce aquí tu código
enum FightResult {
    case victoria
    case derrota
    case empate
}

// Introduce aquí tu código
extension Hand {
    // V1
    /*
    func fight(opponent: Hand) -> FightResult {
        switch(self, opponent) {
            case (.piedra, .papel): return .derrota
            case (.piedra, .tijera): return .victoria
            case (.papel, .piedra): return .victoria
            case (.papel, .tijera): return .derrota
            case (.tijera, .piedra): return .derrota
            case (.tijera, .papel): return .victoria
            default: return .empate
        }
    }
    */
    // V2
    func fight(opponent: Hand) -> FightResult {
        switch(self) {
            case .piedra:
                switch(opponent) {
                    case .piedra: return .empate
                    case .papel: return .derrota
                    case .tijera: return .victoria
                }
            case .papel:
                switch(opponent) {
                    case .piedra: return .victoria
                    case .papel: return .empate
                    case .tijera: return .derrota
                }
            case .tijera:
                switch(opponent) {
                    case .piedra: return .derrota
                    case .papel: return .victoria
                    case .tijera: return .empate
                }
        }
    }
}

func testFight(player: Hand, opponent: Hand, expected: FightResult) {
    let result = player.fight(opponent: opponent)
    if result != expected {
        print("Error: \(player) vs \(opponent) debería resultar en \(expected), pero tu código devuelve \(result)")
    }
}

testFight(player: .piedra, opponent: .papel,  expected: .derrota)
testFight(player: .tijera, opponent: .tijera, expected: .empate)
testFight(player: .papel,  opponent: .piedra, expected: .victoria)

extension Hand {
    static func random() -> Hand {
        // Introduce aquí tu código
        return [.piedra, .papel, .tijera].randomElement()!
    }
}

print(Hand.random())

func partida() {
    let jugador = Hand.random()
    let rival = Hand.random()
    jugador.fight()
}

partida()


