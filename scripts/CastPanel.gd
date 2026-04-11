extends PanelContainer

var stats: AntStats = null
var anthill_ref = null

@onready var label_nombre: Label = $CastContainer/LabelNombre
@onready var label_costo: Label = $CastContainer/LabelCosto
@onready var label_tiempo: Label = $CastContainer/LabelTiempo
@onready var button_crear: Button = $CastContainer/ButtonCrear

func setup(ant_stats: AntStats, anthill):
	stats = ant_stats
	anthill_ref = anthill
	label_nombre.text = stats.nombre
	label_costo.text = "Costo: " + str(stats.costo_hojas) + " hojas"
	label_tiempo.text = "Tiempo: " + str(stats.tiempo_creacion) + "s"
	button_crear.pressed.connect(_on_crear_pressed)

func _on_crear_pressed():
	var exito = SpawnQueue.agregar_a_cola(stats, anthill_ref)
	if not exito:
		print("hojas insuficientes")
