class_name TreeInterior
extends Node2D

## Submapa interior del árbol: pisos + puntos de hoja + cámara propia.

signal salir_pedido

@onready var camara: Camera2D = $CamaraArbol
@onready var pisos: Node2D = $Pisos
@onready var punto_entrada: Marker2D = $PuntoEntrada
@onready var contenedor_escaladores: Node2D = $Escaladores

var vista_activa: bool = false

func _ready():
	camara.enabled = false
	visible = false

func obtener_punto_libre() -> LeafPoint:
	var candidatos: Array = []
	for piso in pisos.get_children():
		for hoja in piso.get_children():
			if hoja is LeafPoint and hoja.disponible and not hoja.reservado:
				candidatos.append(hoja)
	if candidatos.is_empty():
		return null
	return candidatos[randi() % candidatos.size()]

func hojas_disponibles() -> int:
	var total := 0
	for piso in pisos.get_children():
		for hoja in piso.get_children():
			if hoja is LeafPoint and hoja.disponible:
				total += 1
	return total

func mostrar_vista(camara_anterior: Camera2D):
	visible = true
	camara.enabled = true
	camara.make_current()
	vista_activa = true

func ocultar_vista(camara_anterior: Camera2D):
	visible = false
	camara.enabled = false
	camara_anterior.make_current()
	vista_activa = false

func _on_boton_salir_pressed():
	emit_signal("salir_pedido")
