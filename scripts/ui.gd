extends CanvasLayer

const AntGroupScene = preload("res://scenes/AntGroup.tscn")

var spawn_polygon: Array = [
	Vector2(100, 100),
	Vector2(300, 100),
	Vector2(300, 300),
	Vector2(100, 300)
]

@onready var spawn_button: Button = $SpawnButton
@onready var ant_groups_container = get_tree().get_root().get_node("Main/AntGroups")
@onready var spawn_zone: Polygon2D = get_tree().get_root().get_node("Main/SpawnZone")

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
