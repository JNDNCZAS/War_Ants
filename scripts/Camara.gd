class_name Camara
extends RefCounted

var origen: Vector2i = Vector2i.ZERO
var ancho: int = 1
var alto: int = 1
var tipo: String = "vacio"
var piso: int = 0

func contiene(celda: Vector2i) -> bool:
	return celda.x >= origen.x and celda.x < origen.x + ancho \
		and celda.y >= origen.y and celda.y < origen.y + alto

func total_celdas() -> int:
	return ancho * alto
