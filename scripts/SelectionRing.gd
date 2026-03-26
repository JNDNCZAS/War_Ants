extends Node2D

func _draw():
	draw_arc(Vector2.ZERO, 16.0, 0, TAU, 32, Color(1, 1, 0, 0.9), 2.0)
