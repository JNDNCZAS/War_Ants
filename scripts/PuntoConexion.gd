class_name PuntoConexion
extends Node2D

var piso: int = 0
var celda: Vector2i = Vector2i.ZERO
var destino: PuntoConexion = null
var es_superficie: bool = false

@onready var visual: Polygon2D = $Visual

func _ready():
	actualizar_visual()

func actualizar_visual():
	if visual:
		visual.color = Color(0.2, 0.6, 1.0, 0.95) if destino else Color(1.0, 0.85, 0.1, 0.95)
