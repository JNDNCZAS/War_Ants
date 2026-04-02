class_name AntTree
extends StaticBody2D

var hojas: float = INF

@export var nombre: String = "Árbol"
@onready var area: Area2D = $Area2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	sprite.play("idle")
