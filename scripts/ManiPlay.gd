extends Control


@onready var button_group_modo: ButtonGroup = $ModoGameContainer/HistoriaButton.button_group
@onready var button_group_mapa: ButtonGroup = $MapContainer/Mapa1Button.button_group
@onready var especie_option: OptionButton = $ConfigureContainer/EspecieOption

func _ready():
	$ModoGameContainer/HistoriaButton.button_pressed = true
	$MapContainer/Mapa1Button.button_pressed = true


func _obtener_selecciones():
	var boton_modo = button_group_modo.get_pressed_button()
	var boton_mapa = button_group_mapa.get_pressed_button()
	
	
	var modo = boton_modo.text if boton_modo else "ninguno"
	var mapa = boton_mapa.text if boton_mapa else "ninguno"
	var especie_selec = especie_option.get_item_text(especie_option.selected)
	

	
	
	return {
		"especie": especie_selec,
		"modo": modo,
		"mapa": mapa
	}

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")
	
	
func _on_jugar_pressed():
	var selecciones = _obtener_selecciones()
	
	if selecciones.especie == "Selecciona una especie" or selecciones.especie == "":
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
			
			

func _on_histo_pressed():
	pass

func _on_super_pressed():
	pass

func _on_rey_pressed():
	pass

func _on_dios_pressed():
	pass

func _on_mapa2_pressed():
	pass

func _on_mapa3_pressed():
	pass

func _on_mapa4_pressed():
	pass

func _on_opcion1_pressed():
	pass

func _on_opcion2_pressed():
	pass

func _obtener_modo_seleccionado():
	pass
