extends Control


@onready var button_group_modo: ButtonGroup = $ModoGameContainer/HistoriaButton.button_group
@onready var button_group_mapa: ButtonGroup = $MapContainer/Mapa1Button.button_group


func _ready():
	$ModoGameContainer/HistoriaButton.button_pressed = true
	$MapContainer/Mapa1Button.button_pressed = true
	print("ButtonGroup HistoriaButton: ", $ModoGameContainer/HistoriaButton.button_group)
	print("ButtonGroup Mapa1Button: ", $MapContainer/Mapa1Button.button_group)

func _obtener_selecciones():
	var boton_modo = button_group_modo.get_pressed_button()
	var boton_mapa = button_group_mapa.get_pressed_button()
	
	var modo = boton_modo.text if boton_modo else "ninguno"
	var mapa = boton_mapa.text if boton_mapa else "ninguno"
	
	print("Modo seleccionado: ", modo)
	print("Mapa seleccionado: ", mapa)
	
	return {
		"modo": modo,
		"mapa": mapa
	}

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu.tscn")
	
	
func _on_jugar_pressed():
	_obtener_selecciones()
