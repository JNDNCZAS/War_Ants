extends Node

signal grupo_creado(stats)

var cola: Array = []
var timer_actual: float = 0.0
var procesando: bool = false
var anthill = null

func _process(delta):
	if cola.is_empty() or not procesando:
		return
	timer_actual -= delta
	if timer_actual <= 0:
		_crear_grupo()
		cola.pop_front()
		if not cola.is_empty():
			timer_actual = cola[0].tiempo_creacion
		else:
			procesando = false

func agregar_a_cola(stats: AntStats, hojas_ref) -> bool:
	if hojas_ref.hojas_almacenadas < stats.costo_hojas:
		return false
	hojas_ref.hojas_almacenadas -= stats.costo_hojas
	cola.append(stats)
	if not procesando:
		procesando = true
		timer_actual = stats.tiempo_creacion
	return true

func _crear_grupo():
	if anthill == null:
		return
	var stats = cola[0]
	emit_signal("grupo_creado", stats)

func get_progreso() -> float:
	if cola.is_empty() or not procesando:
		return 0.0
	return 1.0 - (timer_actual / cola[0].tiempo_creacion)
