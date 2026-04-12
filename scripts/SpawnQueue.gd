extends Node

signal grupo_creado(stats)
signal cola_actualizada(cola_stats)
signal progreso_actualizado(valor)

var cola: Array = []
var timer_actual: float = 0.0
var procesando: bool = false
var anthill = null

func _process(delta):
	if cola.is_empty() or not procesando:
		return
	timer_actual -= delta
	emit_signal("progreso_actualizado", get_progreso())
	if timer_actual <= 0:
		_crear_grupo()
		cola.pop_front()
		emit_signal("cola_actualizada", cola)
		if not cola.is_empty():
			timer_actual = cola[0].tiempo_creacion
		else:
			procesando = false

func agregar_a_cola(stats: AntStats, hojas_ref) -> bool:
	if hojas_ref.hojas_almacenadas < stats.costo_hojas:
		return false
	hojas_ref.hojas_almacenadas -= stats.costo_hojas
	cola.append(stats)
	emit_signal("cola_actualizada", cola)
	if not procesando:
		procesando = true
		timer_actual = stats.tiempo_creacion
	return true

func _crear_grupo():
	if cola.is_empty():
		return
	emit_signal("grupo_creado", cola[0])

func get_progreso() -> float:
	if cola.is_empty() or not procesando:
		return 0.0
	return 1.0 - (timer_actual / cola[0].tiempo_creacion)
	
	
func cancelar(indice: int):
	if indice < 0 or indice >= cola.size():
		return
	var stats_cancelado = cola[indice]
	anthill.hojas_almacenadas += stats_cancelado.costo_hojas
	cola.remove_at(indice)
	emit_signal("cola_actualizada", cola)
	if indice == 0:
		if not cola.is_empty():
			timer_actual = cola[0].tiempo_creacion
		else:
			procesando = false
