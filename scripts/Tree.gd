class_name AntTree
extends StaticBody2D

var hojas: float = 500

@export var nombre: String = "Árbol"
@onready var area: Area2D = $Area2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	sprite.play("idle")

func reducir_hojas(cantidad: float) -> float:
	var cantidad_real = min(cantidad, hojas)
	hojas -= cantidad_real
	if hojas <= 0:
		queue_free()
	return cantidad_real
