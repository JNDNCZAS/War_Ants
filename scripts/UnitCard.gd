extends Control

#==================================================
# REFERENCIAS A NODOS VISUALES PRINCIPALES
#==================================================

@onready var texture_rect: TextureRect = $CardBG/TextureRect
@onready var tooltip: PanelContainer = $Tooltip
@export var stats: AntStats
#==================================================
# REFERENCIAS A LABELS DEL TOOLTIP
#==================================================

@onready var label_nombre: Label = $Tooltip/VBoxContainer/LabelNombre
@onready var label_especie: Label = $Tooltip/VBoxContainer/LabelEspecie
@onready var label_vida: Label = $Tooltip/VBoxContainer/LabelIntegrantes
@onready var label_velocidad: Label = $Tooltip/VBoxContainer/LabelVelocidad
@onready var label_daño: Label = $Tooltip/VBoxContainer/LabelDaño
@onready var label_defensa: Label = $Tooltip/VBoxContainer/LabelDefensa
@onready var label_carga: Label = $Tooltip/VBoxContainer/LabelCarga
@onready var label_reduccion: Label = $Tooltip/VBoxContainer/LabelReduccion

#==================================================
# DATOS ASOCIADOS
#==================================================

var ant_group = null


func _ready():
	tooltip.top_level = true
	tooltip.visible = false
	await get_tree().process_frame
	tooltip.custom_minimum_size = Vector2(160, 180)
	tooltip.size = Vector2(160, 180)
	custom_minimum_size = Vector2(80, 80)
	size = Vector2(80, 80)
	print("UnitCard size después de forzar: ", size)

func setup(group):
	ant_group = group
	if group.stats:
		label_nombre.text = group.stats.nombre
		label_especie.text = group.stats.especie
		label_vida.text = "Integrantes: " + str(group.integrantes_actuales)
		label_velocidad.text = "Velocidad: " + str(group.stats.velocidad)
		label_daño.text = "Daño: " + str(group.stats.daño)
		label_defensa.text = "Defensa: " + str(group.stats.defensa)
		label_carga.text = "Carga: " + str(group.stats.capacidad_carga)
		label_reduccion.text = "Vel. carga: " + str(group.stats.reduccion_velocidad_carga)
	var sprite_frames = group.sprite.sprite_frames
	if sprite_frames:
		var frame_texture = sprite_frames.get_frame_texture("walk", 0)
		texture_rect.texture = frame_texture

func _on_mouse_entered():
	tooltip.visible = true
	tooltip.global_position = global_position + Vector2(0, -tooltip.size.y)

func _on_mouse_exited():
	tooltip.visible = false
