extends Control


func _on_jugar_pressed():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_config_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/Config.tscn")
	
func _on_wiki_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/Wiki.tscn")
	
func _on_credi_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/Credits.tscn")
	
func _on_salir_pressed():
	get_tree().quit()
