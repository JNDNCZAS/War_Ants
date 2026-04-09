extends Control

func _ready():
	$ButtonContainer/ButtonJugar.pressed.connect(_on_jugar_pressed)
	$ButtonContainer/ButtonSalir.pressed.connect(_on_salir_pressed)

func _on_jugar_pressed():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_salir_pressed():
	get_tree().quit()
