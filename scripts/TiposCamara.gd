extends Node

const TIPOS := {
	"vacio":      {"nombre": "Vacío",              "color": Color(0.55, 0.38, 0.22)},
	"conexion":   {"nombre": "Conexión",           "color": Color(0.2, 0.6, 1.0)},
	"almacen":    {"nombre": "Almacén de comida",  "color": Color(0.9, 0.7, 0.1)},
	"basurero":   {"nombre": "Basurero",           "color": Color(0.4, 0.25, 0.1)},
	"reina":      {"nombre": "Cámara de la reina", "color": Color(0.8, 0.1, 0.6)},
	"incubacion": {"nombre": "Incubación",         "color": Color(0.9, 0.9, 0.6)},
	"cria":       {"nombre": "Cría",               "color": Color(0.6, 0.9, 0.6)},
	"cultivo":    {"nombre": "Cultivo",            "color": Color(0.3, 0.8, 0.3)},
}

func color_de(tipo: String) -> Color:
	return TIPOS.get(tipo, TIPOS["vacio"])["color"]

func nombre_de(tipo: String) -> String:
	return TIPOS.get(tipo, TIPOS["vacio"])["nombre"]

func lista_tipos() -> Array:
	return TIPOS.keys()
