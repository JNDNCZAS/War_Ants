extends Node2D

@export var duracion: float = 1.2
var timer: float = 0.0

func _process(delta):
	timer += delta
	# efecto de rebote hacia abajo
	var offset = sin(timer * 8.0) * 5.0
	position.y += offset * delta
	# desvanece al final
	modulate.a = 1.0 - (timer / duracion)
	if timer >= duracion:
		queue_free()

func _draw():
	# dibuja 3 flechas apuntando hacia abajo en diferentes alturas
	var color = Color(1, 1, 1, 1)
	var offset_y = 0.0
	for i in 3:
		offset_y = i * -12.0
		# cuerpo de la flecha
		draw_line(Vector2(0, offset_y), Vector2(0, offset_y + 8.0), color, 2.0)
		# punta izquierda
		draw_line(Vector2(0, offset_y + 8.0), Vector2(-5.0, offset_y + 3.0), color, 2.0)
		# punta derecha
		draw_line(Vector2(0, offset_y + 8.0), Vector2(5.0, offset_y + 3.0), color, 2.0)
