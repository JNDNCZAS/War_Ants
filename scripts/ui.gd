extends CanvasLayer

#==================================================
# PRELOADS
#==================================================
const AntGroupScene = preload("res://scenes/AntGroup.tscn")
const UnitCardScene = preload("res://scenes/UI/UnitCard.tscn")
const CastPanelScene = preload("res://scenes/UI/CastPanel.tscn")
const QueueCardScene = preload("res://scenes/UI/QueueCard.tscn")
#==================================================
# REFERENCIAS A NODOS UI
#==================================================
@onready var label_hojas: Label = $ResourcePanel/VBoxContainer/LabelHojas
@onready var selection_label: Label = $SelectionLabel
@onready var total_label: Label = $TotalLabel
@onready var unit_container: HBoxContainer = $BottomPanel/UnitContainer
@onready var cast_container: HBoxContainer = $CastPanel/CastContainer
@onready var queue_container: HBoxContainer = $QueuePanel/QueueContainer

#==================================================
# REFERENCIAS A NODOS DEL MUNDO
#==================================================
@onready var ant_groups_container = get_tree().get_root().get_node("Main/AntGroups")
@onready var anthill = get_tree().get_first_node_in_group("anthill")

#==================================================
# READY
#==================================================
func _ready():
	SpawnQueue.anthill = anthill
	SpawnQueue.grupo_creado.connect(_on_grupo_creado)
	SpawnQueue.cola_actualizada.connect(_on_cola_actualizada)
	SpawnQueue.progreso_actualizado.connect(_on_progreso_actualizado)
	_cargar_castas()

#==================================================
# PROCESS
#==================================================
func _process(_delta):
	var total_integrantes = 0
	for group in ant_groups_container.get_children():
		total_integrantes += group.integrantes_actuales
	total_label.text = "Hormigas en mapa: " + str(total_integrantes)
	if anthill:
		label_hojas.text = "Hojas: " + str(anthill.hojas_almacenadas)

#==================================================
# CASTAS
#==================================================
func _cargar_castas():
	var especie = GameData.especie
	print("especie en GameData: '", especie, "'")
	for stats in StatsLoader.todos_los_stats:
		print("especie en stats: '", stats.especie, "'")
		if stats.especie == especie:
			var panel = CastPanelScene.instantiate()
			cast_container.add_child(panel)
			panel.setup(stats, anthill)

func _on_grupo_creado(stats: AntStats):
	var group = AntGroupScene.instantiate()
	# zona de spawn a la derecha del hormiguero
	var offset = Vector2(
		randf_range(50, 150),   # desplazamiento a la derecha
		randf_range(-50, 50)    # variación vertical
	)
	group.global_position = anthill.global_position + offset
	ant_groups_container.add_child(group)
	group.stats = stats
	group.integrantes_actuales = stats.integrantes_max

#==================================================
# PANEL DE SELECCION
#==================================================
func _actualizar_panel(selected_groups: Array):
	for child in unit_container.get_children():
		child.queue_free()
	for group in selected_groups:
		var card = UnitCardScene.instantiate()
		unit_container.add_child(card)
		card.setup(group)

func _on_cola_actualizada(cola_stats: Array):
	for child in queue_container.get_children():
		child.queue_free()
	for i in cola_stats.size():
		var card = QueueCardScene.instantiate()
		queue_container.add_child(card)
		card.setup(cola_stats[i], i)
		
		
func _on_progreso_actualizado(valor: float):
	var cards = queue_container.get_children()
	if cards.size() > 0:
		cards[0].actualizar_progreso(valor)
