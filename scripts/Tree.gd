class_name AntTree
extends StaticBody2D

@export var nombre: String = "Árbol"

@onready var area: Area2D = $Area2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interior: TreeInterior = $TreeInterior

func _ready():
	sprite.play("idle")

## Compatibilidad con UI que quiera mostrar "hojas restantes".
func hojas_disponibles() -> int:
	if interior:
		return interior.hojas_disponibles()
	return 0
