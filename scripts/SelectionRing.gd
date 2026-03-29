extends Node2D

var is_selected: bool = false

func _draw():
	if is_selected:
		draw_arc(Vector2.ZERO, 16.0, 0, TAU, 32, Color(1, 1, 0, 0.9), 3.0)

func set_selected(value: bool):
	is_selected = value
	visible = is_selected
	queue_redraw()
