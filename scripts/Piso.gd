class_name Piso
extends Node2D

enum Celda {VACIO, TUNEL, CAMARA}

const TAMANO_CELDA: float = 64.0

@export var indice: int = 1
@export var ancho_celdas: int = 40
@export var alto_celdas: int = 30
var astar: AStar2D = AStar2D.new()

var celdas: Dictionary = {}  # Vector2i -> Celda

@onready var dibujo: Node2D = $Dibujo
var camaras: Array = []  # Array[Camara]

func _ready():
	PisoManager.registrar_piso(indice, self)

func limite_izq() -> float:
	return global_position.x
func limite_arriba() -> float:
	return global_position.y
func limite_der() -> float:
	return global_position.x + ancho_celdas * TAMANO_CELDA
func limite_abajo() -> float:
	return global_position.y + alto_celdas * TAMANO_CELDA
func centro_region() -> Vector2:
	return global_position + Vector2(ancho_celdas, alto_celdas) * TAMANO_CELDA / 2.0

func celda_valida(celda: Vector2i) -> bool:
	return celda.x >= 0 and celda.y >= 0 and celda.x < ancho_celdas and celda.y < alto_celdas

func mundo_a_celda(pos_mundo: Vector2) -> Vector2i:
	var local = pos_mundo - global_position
	return Vector2i(floori(local.x / TAMANO_CELDA), floori(local.y / TAMANO_CELDA))

func celda_a_mundo_centro(celda: Vector2i) -> Vector2:
	return global_position + Vector2(celda.x + 0.5, celda.y + 0.5) * TAMANO_CELDA

func excavar_tunel(celda: Vector2i):
	if not celda_valida(celda):
		return
	if celdas.get(celda, Celda.VACIO) == Celda.VACIO:
		celdas[celda] = Celda.TUNEL
		_agregar_celda_a_grafo(celda)
		dibujo.queue_redraw()

func excavar_camara(celda_inicio: Vector2i, ancho: int, alto: int) -> Camara:
	for x in range(ancho):
		for y in range(alto):
			var c = celda_inicio + Vector2i(x, y)
			if celda_valida(c):
				celdas[c] = Celda.CAMARA
				_agregar_celda_a_grafo(c)
	var camara = Camara.new()
	camara.origen = celda_inicio
	camara.ancho = ancho
	camara.alto = alto
	camara.piso = indice
	camaras.append(camara)
	dibujo.queue_redraw()
	return camara
	
func camara_en_celda(celda: Vector2i) -> Camara:
	for c in camaras:
		if c.contiene(celda):
			return c
	return null
	
func _id_de_celda(celda: Vector2i) -> int:
	return celda.y * ancho_celdas + celda.x

func _vecinos(celda: Vector2i) -> Array:
	return [celda + Vector2i(1, 0), celda + Vector2i(-1, 0), celda + Vector2i(0, 1), celda + Vector2i(0, -1)]

func _agregar_celda_a_grafo(celda: Vector2i):
	var id = _id_de_celda(celda)
	if not astar.has_point(id):
		astar.add_point(id, celda_a_mundo_centro(celda))
	for vecino in _vecinos(celda):
		if celda_valida(vecino) and celdas.get(vecino, Celda.VACIO) != Celda.VACIO:
			var id_vecino = _id_de_celda(vecino)
			if not astar.has_point(id_vecino):
				astar.add_point(id_vecino, celda_a_mundo_centro(vecino))
			if not astar.are_points_connected(id, id_vecino):
				astar.connect_points(id, id_vecino)

func camino_entre(desde_mundo: Vector2, hasta_mundo: Vector2) -> PackedVector2Array:
	var id_desde = _id_de_celda(mundo_a_celda(desde_mundo))
	var id_hasta = _id_de_celda(mundo_a_celda(hasta_mundo))
	if not astar.has_point(id_desde) or not astar.has_point(id_hasta):
		return PackedVector2Array()
	return astar.get_point_path(id_desde, id_hasta)
