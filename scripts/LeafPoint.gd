class_name LeafPoint
extends Marker2D

## Punto individual de hoja dentro de un piso del árbol.
## Se reserva, se corta, y se regenera solo después de tiempo_respawn.

signal hoja_disponible

@export var tiempo_respawn: float = 30.0
@export var cantidad_hoja: float = 1.0

var disponible: bool = true
var reservado: bool = false

var _timer_respawn: float = 0.0

@onready var visual: Polygon2D = $Visual

func _ready():
	_actualizar_visual()

func _process(delta):
	if not disponible:
		_timer_respawn -= delta
		if _timer_respawn <= 0.0:
			disponible = true
			reservado = false
			_actualizar_visual()
			emit_signal("hoja_disponible")

func reservar() -> bool:
	if disponible and not reservado:
		reservado = true
		return true
	return false

func liberar_reserva():
	if disponible:
		reservado = false

func cortar() -> float:
	disponible = false
	reservado = true
	_timer_respawn = tiempo_respawn
	_actualizar_visual()
	return cantidad_hoja

func _actualizar_visual():
	if visual:
		visual.visible = disponible
