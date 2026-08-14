class_name EscaladorVisual
extends Node2D

@onready var sprite: AnimatedSprite2D = $Sprite

func configurar(sprite_frames: SpriteFrames):
	if sprite_frames:
		sprite.sprite_frames = sprite_frames
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("walk"):
		sprite.play("walk")
