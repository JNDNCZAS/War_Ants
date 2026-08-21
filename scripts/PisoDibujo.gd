extends Node2D

@onready var piso: Piso = get_parent()

func _ready():
	z_index = -10
	PisoManager.modo_tipos_cambiado.connect(func(_activo): queue_redraw())

func _draw():
	var t = Piso.TAMANO_CELDA
	draw_rect(Rect2(0, 0, piso.ancho_celdas * t, piso.alto_celdas * t), Color(0.15, 0.1, 0.07))
	for celda in piso.celdas:
		var estado = piso.celdas[celda]
		var color: Color
		if estado == Piso.Celda.TUNEL:
			color = Color(0.35, 0.24, 0.15)
		else:
			var camara = piso.camara_en_celda(celda)
			if PisoManager.modo_tipos_activo and camara:
				color = TiposCamara.color_de(camara.tipo)
			else:
				color = Color(0.55, 0.38, 0.22)
		draw_rect(Rect2(celda.x * t, celda.y * t, t, t), color)
	var color_linea = Color(1, 1, 1, 0.08)
	for x in range(piso.ancho_celdas + 1):
		draw_line(Vector2(x * t, 0), Vector2(x * t, piso.alto_celdas * t), color_linea, -1.0)
	for y in range(piso.alto_celdas + 1):
		draw_line(Vector2(0, y * t), Vector2(piso.ancho_celdas * t, y * t), color_linea, -1.0)
