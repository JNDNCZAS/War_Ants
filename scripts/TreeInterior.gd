class_name TreeInterior
extends CanvasLayer

signal salir_pedido

@onready var pisos: Node2D = $Centro/Contenido/Pisos
@onready var punto_entrada: Marker2D = $Centro/Contenido/PuntoEntrada
@onready var contenedor_escaladores: Node2D = $Centro/Contenido/Escaladores

var vista_activa: bool = false

func _ready():
	visible = false
	layer = 10

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

func mostrar_vista():
	visible = true
	vista_activa = true

func ocultar_vista():
	visible = false
	vista_activa = false

func _on_boton_salir_pressed():
	emit_signal("salir_pedido")
