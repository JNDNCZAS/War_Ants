extends Control


@onready var button_group_modo: ButtonGroup = $ModoGameContainer/HistoriaButton.button_group
@onready var button_group_mapa: ButtonGroup = $MapContainer/Mapa1Button.button_group
@onready var especie_option: OptionButton = $ConfigureContainer/EspecieOption

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
	var especie_selec = especie_option.get_item_text(especie_option.selected)
	
	print("especie seleccionada: ", especie_selec)
	print("Modo seleccionado: ", modo)
	print("Mapa seleccionado: ", mapa)
	
	
	return {
		"especie": especie_selec,
		"modo": modo,
		"mapa": mapa
	}

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu.tscn")
	
	
func _on_jugar_pressed():
	var selecciones = _obtener_selecciones()
	
	if selecciones.especie == "Selecciona una especie" or selecciones.especie == "":
		print("debes seleccionar una especie")
		return
	
	GameData.modo_juego = selecciones.modo
	GameData.mapa = selecciones.mapa
	GameData.especie = selecciones.especie
	
	match selecciones.mapa:
		"Mapa 1":
			get_tree().change_scene_to_file("res://scenes/Main.tscn")
		"Mapa 2":
			get_tree().change_scene_to_file("res://scenes/Main.tscn")
		_:
			get_tree().change_scene_to_file("res://scenes/Main.tscn")
