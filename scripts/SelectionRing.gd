extends Node2D

var is_selected: bool = false
var estado_color: Color = Color(1, 1, 0, 0.9)  # amarillo por defecto

func _draw():
	if is_selected:
		draw_arc(Vector2.ZERO, 16.0, 0, TAU, 32, estado_color, 3.0)

func set_selected(value: bool):
	is_selected = value
	visible = is_selected
	queue_redraw()

func set_estado_color(color: Color):
	estado_color = color
	queue_redraw()
