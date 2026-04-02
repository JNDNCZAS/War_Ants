class_name Tree
extends StaticBody2D

@export var nombre: String = "Árbol"
var hojas: float = INF

@onready var area: Area2D = $Area2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	sprite.play("idle")
