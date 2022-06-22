enum MasterMindColor {
    case red
    case green
    case yellow
    case blue
    case black
    case white
}

extension MasterMindColor {
    var emoji: String {
        switch self {
            case .red   : return "🔴"
            case .green : return "🟢"
            case .yellow: return "🟡"
            case .blue  : return "🔵"
            case .black : return "⚫"
            case .white : return "⚪"
        }
    }
}

enum MasterMindError: Error {
    case wrongCharacter    // The user supplied a wrong Character to `from`
}

extension MasterMindColor {
    static func from(emoji: Character) throws -> MasterMindColor {        
        switch emoji {
            case "🔴": return .red
            case "🟢": return .green
            case "🟡": return .yellow
            case "🔵": return .blue
            case "⚫": return .black
            case "⚪": return .white
            default: throw MasterMindError.wrongCharacter
        }
    }
}

extension MasterMindColor: CustomStringConvertible {
    public var description: String { return emoji }
}

extension MasterMindColor {
    static func from(letter: Character) throws -> MasterMindColor {        
        // Your code here
        switch letter{
            case "r", "R": return .red
            case "g", "G": return .green
            case "y", "Y": return .yellow
            case "b", "B": return .blue
            case "k", "K": return .black
            case "W", "w": return .white
            default : return try MasterMindColor.from(emoji:letter)
        }
        
    }
}

do {
    let black = try MasterMindColor.from(letter: "K")
    let blue = try MasterMindColor.from(letter: "b")
    if black != .black { print("Error al convertir 'K' al color negro.") }
    if blue != .blue { print("Error al convertir 'b' al color azul.")}
} catch {
    print("Se ha producido una excepción incorrecta")
}

/*do {
    try MasterMindColor.from(letter: "p")
    print("Error: la letra `p` no debería tener ningún color asociado, debería haberse lanzado una excepción.")
} catch {}*/


extension String {
    func toMasterMindColorCombination() throws -> [MasterMindColor] {
        return try self.map { try MasterMindColor.from(letter: $0) }
    }
}



/*do {
    try print("kskej".toMasterMindColorCombination())
} catch {
    print("Error")
}*/


struct MasterMindGame {
    private let secretCode: [MasterMindColor]
    
    let maxTurns = 10
    var currentTurn = 0
    var win = false
    
    static func randomCode(colors: Int) -> [MasterMindColor] {
        // Your code here.
        let options : [MasterMindColor] = [.red, .yellow, .blue, .green, .black, .white]
        var randomColors = [MasterMindColor]()
        for _ in 0..<colors{
          randomColors.append(options.randomElement()!)
            
        }
        return randomColors
        
    }
    
    init(_ secretCode: String? = nil) {
        // Your code here.
        if secretCode != nil {
            do {
                self.secretCode = try secretCode!.toMasterMindColorCombination()
            } catch {
                self.secretCode = MasterMindGame.randomCode(colors: 4)
            }
        }else{
            self.secretCode = MasterMindGame.randomCode(colors: 4)
        }        
        
        
    }
}


extension MasterMindGame{
    func countExactMatches(_ combination:[MasterMindColor]) -> Int{
        var exactGuess = 0
        guard combination.count == self.secretCode.count else{
            return 0
        } 
        for i in 0..<combination.count{
           
            if combination[i] == self.secretCode[i]{
                exactGuess += 1
            }
        }
        return exactGuess
    }  
            
}

extension MasterMindGame{
    func countPartialMatches(_ combination:[MasterMindColor]) -> Int{
        var partialGuess = 0
        var diferentCombination = [MasterMindColor]()
        var diferentSecretCode = [MasterMindColor]()
        guard combination.count == self.secretCode.count else{
            return 0
        }
        for i in 0..<combination.count{
            if combination[i] != self.secretCode[i]{
                diferentCombination.append(combination[i])
                diferentSecretCode.append(self.secretCode[i])
            }
        }
        
        for v in diferentSecretCode{
            if let index = diferentCombination.firstIndex(of: v){
               partialGuess += 1
               diferentCombination.remove(at: index)  
           }
        } 
        return partialGuess
    }
}


extension MasterMindGame {
    mutating func newTurn(_ guess: String) {
        // Your code here
    
        var combinationUser = [MasterMindColor]()
        do{
            combinationUser = try guess.toMasterMindColorCombination()
        }catch{
            print("Combinación incorrecta. Por favor, prueba de nuevo.")
        }
        guard combinationUser.count == self.secretCode.count else{
            print("Debes hacer una apuesta con \(self.secretCode.count) colores. Por favor, prueba de nuevo.")
            return
        }
        guard self.currentTurn != self.maxTurns && !self.win else {  
            print("El juego ha terminado.")
            return
        }
        let exactMatches = countExactMatches(combinationUser)
        let partialMatches = countPartialMatches(combinationUser)
        print("Combinación seleccionada por el usuario: \(combinationUser).")
        print("Número de aciertos: \(exactMatches)")
        print("Número de semiaciertos: \(partialMatches)")
        
        self.currentTurn += 1
        guard exactMatches != self.secretCode.count else {
            print("Has ganado en el turno \(self.currentTurn)!")
            self.win = true
            return
        }
        guard exactMatches == self.secretCode.count else {
            print("Lo siento, has perdido. Otra vez será!")
            return
        }
        
    }
}






