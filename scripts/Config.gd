extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu.tscn")
