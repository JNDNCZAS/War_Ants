extends Node

var todos_los_stats: Array = []

func _ready():
	_cargar_stats()

func _cargar_stats():
	var dir = DirAccess.open("res://data/stats/")
	if dir:
		dir.list_dir_begin()
		var archivo = dir.get_next()
		while archivo != "":
			if archivo.ends_with(".tres"):
				var stats = load("res://data/stats/" + archivo)
				if stats:
					todos_los_stats.append(stats)
					print("cargado: ", archivo)
			archivo = dir.get_next()
		dir.list_dir_end()
	print("total stats cargados: ", todos_los_stats.size())

func stats_aleatorio() -> AntStats:
	if todos_los_stats.is_empty():
		return null
	return todos_los_stats[randi() % todos_los_stats.size()]
	
	
func stats_por_especie(especie: String) -> Array:
	var resultado: Array = []
	for s in todos_los_stats:
		if s.especie == especie:
			resultado.append(s)
	return resultado

func stats_aleatorio_por_especie(especie: String) -> AntStats:
	var opciones = stats_por_especie(especie)
	if opciones.is_empty():
		return null
	return opciones[randi() % opciones.size()]
