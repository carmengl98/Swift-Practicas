class Trabajador: CustomStringConvertible {
    var nombre: String
    var nEmpleado: Int
    var sueldo: Double
    var departamento: String
    
    init(nombre: String, nEmpleado: Int, sueldo: Double, departamento: String) {
        self.nombre = nombre
        self.nEmpleado = nEmpleado
        self.sueldo = sueldo
        self.departamento = departamento
    }
    
    var description: String {
        "Mi nombre es \(nombre) y mi número de empleado es \(nEmpleado). Tengo un sueldo base anual de \(sueldo) € y trabajo en el departamento de \(departamento)"
    }
    
    func gananciaEn(anos: Int) -> Double {
        return sueldo * Double(anos)
    }
}

class Directivo: Trabajador {
    let sueldoBase: Double = 60000
    
    init(nombre: String, nEmpleado: Int, departamento: String) {
        super.init(nombre: nombre, nEmpleado: nEmpleado, sueldo: sueldoBase, departamento: departamento)
    }
}

class Empleado: Trabajador {
    let sueldoBase: Double = 40000
    
    init(nombre: String, nEmpleado: Int, departamento: String) {
        super.init(nombre: nombre, nEmpleado: nEmpleado, sueldo: sueldoBase, departamento: departamento)
    }
}

class Becario: Trabajador {
    let sueldoBase: Double = 10000
    
    init(nombre: String, nEmpleado: Int, departamento: String) {
        super.init(nombre: nombre, nEmpleado: nEmpleado, sueldo: sueldoBase, departamento: departamento)
    }
}

let empresa = [Directivo(nombre: "Julio Iglesias", nEmpleado: 1, departamento: "Canciones"), 
               Directivo(nombre: "Raphael", nEmpleado: 2, departamento: "Canciones"),
               Empleado(nombre: "David Bisbal", nEmpleado: 3, departamento: "Relaciones Internacionales"),
               Empleado(nombre: "David Bustamante", nEmpleado: 4, departamento: "R.R.H.H."),
               Becario(nombre: "Pablo Alborán", nEmpleado: 5, departamento: "Ventas")
              ]

var totalAPagar2 = 0.0
var totalAPagar4 = 0.0
var totalAPagar5 = 0.0
for trabajador in empresa {
    print(trabajador)
    totalAPagar2 += trabajador.gananciaEn(anos: 2)
    totalAPagar4 += trabajador.gananciaEn(anos: 4)
    totalAPagar5 += trabajador.gananciaEn(anos: 5)
}
print()
print("2 años: \(totalAPagar2)")
print("4 años: \(totalAPagar4)")
print("5 años: \(totalAPagar5)")
print()
for trabajador in empresa {
    trabajador.departamento = "Ventas"
    print(trabajador)
}

