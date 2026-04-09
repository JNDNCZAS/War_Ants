extends Control

func _ready():
	$ButtonContainer/ButtonJugar.pressed.connect(_on_jugar_pressed)
	$ButtonContainer/ButtonConfiguraciones.pressed.connect(_on_config_pressed)
	$ButtonContainer/ButtonWiki.pressed.connect(_on_wiki_pressed)
	$ButtonContainer/ButtonCreditos.pressed.connect(_on_credi_pressed)
	$ButtonContainer/ButtonSalir.pressed.connect(_on_salir_pressed)
	
func _on_jugar_pressed():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_config_pressed():
	pass
	
func _on_wiki_pressed():
	pass
	
func _on_credi_pressed():
	get_tree().change_scene_to_file("res://scenes/Credits.tscn")
	
func _on_salir_pressed():
	get_tree().quit()
