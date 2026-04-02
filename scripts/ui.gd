extends CanvasLayer

#==================================================
# PRELOADS
#==================================================

const AntGroupScene = preload("res://scenes/AntGroup.tscn")
const UnitCardScene = preload("res://scenes/UnitCard.tscn")

#==================================================
# CONFIGURACIÓN DE SPAWN
#==================================================

var spawn_polygon: Array = [
	Vector2(100, 100),
	Vector2(300, 100),
	Vector2(300, 300),
	Vector2(100, 300)
]

#==================================================
# REFERENCIAS A NODOS UI
#==================================================

@onready var label_hojas: Label = $ResourcePanel/VBoxContainer/LabelHojas
@onready var spawn_button: Button = $SpawnButton
@onready var selection_label: Label = $SelectionLabel
@onready var total_label: Label = $TotalLabel
@onready var unit_container: HBoxContainer = $BottomPanel/UnitContainer

#==================================================
# REFERENCIAS A NODOS DEL MUNDO
#==================================================

@onready var ant_groups_container = get_tree().get_root().get_node("Main/AntGroups")
@onready var spawn_zone: Polygon2D = get_tree().get_root().get_node("Main/SpawnZone")
@onready var anthill = get_tree().get_first_node_in_group("anthill")

func _process(_delta):
	total_label.text = "Grupos en mapa: " + str(ant_groups_container.get_child_count())
	if anthill:
		label_hojas.text = "Hojas: " + str(anthill.hojas_almacenadas)

func _ready():
	spawn_button.pressed.connect(_on_spawn_pressed)
	_draw_spawn_zone()

func _draw_spawn_zone():
	var points = PackedVector2Array()
	for point in spawn_polygon:
		points.append(point)
	spawn_zone.polygon = points

func _on_spawn_pressed():
	var pos = _random_point_in_polygon(spawn_polygon)
	var group = AntGroupScene.instantiate()
	group.global_position = pos
	ant_groups_container.add_child(group)

func _random_point_in_polygon(polygon: Array) -> Vector2:
	var min_x = polygon[0].x
	var max_x = polygon[0].x
	var min_y = polygon[0].y
	var max_y = polygon[0].y
	
	for point in polygon:
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)
	
	var attempts = 0
	while attempts < 100:
		var candidate = Vector2(
			randf_range(min_x, max_x),
			randf_range(min_y, max_y)
		)
		if Geometry2D.is_point_in_polygon(candidate, polygon):
			return candidate
		attempts += 1
	
	return _polygon_center(polygon)

func _polygon_center(polygon: Array) -> Vector2:
	var center = Vector2.ZERO
	for point in polygon:
		center += point
	return center / polygon.size()


func _actualizar_panel(selected_groups: Array):
	for child in unit_container.get_children():
		child.queue_free()
	for group in selected_groups:
		var card = UnitCardScene.instantiate()
		unit_container.add_child(card)
		card.setup(group)
