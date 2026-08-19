class_name Piso
extends Node2D

enum Celda {VACIO, TUNEL, CAMARA}

const TAMANO_CELDA: float = 64.0

@export var indice: int = 1
@export var ancho_celdas: int = 40
@export var alto_celdas: int = 30

var celdas: Dictionary = {}  # Vector2i -> Celda

@onready var dibujo: Node2D = $Dibujo

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
		dibujo.queue_redraw()

func excavar_camara(celda_inicio: Vector2i, ancho: int, alto: int):
	for x in range(ancho):
		for y in range(alto):
			var c = celda_inicio + Vector2i(x, y)
			if celda_valida(c):
				celdas[c] = Celda.CAMARA
	dibujo.queue_redraw()
