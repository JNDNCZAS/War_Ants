extends Node

#==================================================
# CONSTANTES
#==================================================

const DRAG_THRESHOLD = 6.0
const OrderMarkerScene = preload("res://scenes/OrderMarker.tscn")
#==================================================
# REFERENCIAS A NODOS
#==================================================

@onready var ant_groups_container = $"../AntGroups"
@onready var selection_rect_node: ColorRect = $"../SelectionRect"
@onready var ui = $"../UI"
@onready var anthill = get_tree().get_first_node_in_group("anthill")

#==================================================
# SELECCIÓN DE GRUPOS
#==================================================

var selected_groups: Array = []

var drag_start: Vector2 = Vector2.ZERO
var is_dragging: bool = false

#==================================================
# MODOS DE CONTROL
#==================================================

var harvest_mode: bool = false
var patrol_mode: bool = false

#==================================================
# SISTEMA DE PATRULLA
#==================================================

var patrol_points: Array = []


func _ready():
	selection_rect_node.visible = false

func _input(event):
	if event is InputEventKey:
		_handle_key(event)
	elif event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)

func _handle_key(event: InputEventKey):
	if event.keycode == KEY_Z and not event.pressed:
		if patrol_points.size() > 0 and selected_groups.size() > 0:
			for group in selected_groups:
				group.set_patrol(patrol_points.duplicate())
			print("patrulla enviada a ", selected_groups.size(), " grupos con ", patrol_points.size(), " puntos")
		patrol_points.clear()
	if event.keycode == KEY_R:
		if event.pressed and selected_groups.size() > 0:
			harvest_mode = true
		elif not event.pressed:
			harvest_mode = false

func _handle_mouse_button(event: InputEventMouseButton):
	var world_pos = _to_world(event.position)
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			drag_start = world_pos
			is_dragging = false
		else:
			if is_dragging:
				_finish_drag_selection(world_pos)
			else:
				_handle_single_click(world_pos, event)
			is_dragging = false
			selection_rect_node.visible = false
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if Input.is_key_pressed(KEY_Z) and selected_groups.size() > 0:
			patrol_points.append(world_pos)
			_mostrar_marcador(world_pos)
		elif harvest_mode and selected_groups.size() > 0:
			_handle_harvest_click(world_pos)
		elif event.double_click:
			_call_all_groups(world_pos)
		elif selected_groups.size() > 0:
			_issue_move_order(world_pos)

	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if Input.is_key_pressed(KEY_Z) and selected_groups.size() > 0:
			patrol_points.append(world_pos)
			print("punto agregado: ", world_pos, " total puntos: ", patrol_points.size())
		elif event.double_click:
			_call_all_groups(world_pos)
		elif selected_groups.size() > 0:
			_issue_move_order(world_pos)

func _handle_mouse_motion(event: InputEventMouseMotion):
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return
	var world_pos = _to_world(get_viewport().get_mouse_position())
	if drag_start.distance_to(world_pos) > DRAG_THRESHOLD:
		is_dragging = true
		_update_selection_rect(drag_start, world_pos)

func _handle_single_click(world_pos: Vector2, event: InputEventMouseButton):
	if not event.shift_pressed:
		_deselect_all()
	for group in ant_groups_container.get_children():
		if world_pos.distance_to(group.global_position) < 18.0:
			_toggle_select(group)
			break
	_update_selection_label()
	ui._actualizar_panel(selected_groups)

func _finish_drag_selection(end_pos: Vector2):
	var rect = Rect2(drag_start, Vector2.ZERO).expand(end_pos)
	if not Input.is_key_pressed(KEY_SHIFT):
		_deselect_all()
	for group in ant_groups_container.get_children():
		if rect.has_point(group.global_position):
			_select(group)
	_update_selection_label()
	ui._actualizar_panel(selected_groups)

func _issue_move_order(world_pos: Vector2):
	var count = selected_groups.size()
	for i in count:
		var offset = _formation_offset(i, count)
		selected_groups[i].move_to(world_pos + offset)
	_mostrar_marcador(world_pos)

func _call_all_groups(world_pos: Vector2):
	var all_groups = ant_groups_container.get_children()
	var count = all_groups.size()
	for i in count:
		var offset = _formation_offset(i, count)
		all_groups[i].move_to(world_pos + offset)
	_mostrar_marcador(world_pos)
	_update_selection_label()

func _formation_offset(index: int, total: int) -> Vector2:
	if total == 1:
		return Vector2.ZERO
	var cols = ceili(sqrt(float(total)))
	var col = index % cols
	var row = index / cols
	var spacing = 28.0
	var grid_w = (cols - 1) * spacing
	return Vector2(col * spacing - grid_w / 2.0, row * spacing)

func _select(group):
	if group not in selected_groups:
		selected_groups.append(group)
		group.set_selected(true)

func _toggle_select(group):
	if group in selected_groups:
		selected_groups.erase(group)
		group.set_selected(false)
	else:
		selected_groups.append(group)
		group.set_selected(true)

func _deselect_all():
	for group in selected_groups:
		group.set_selected(false)
	selected_groups.clear()
	_update_selection_label()
	ui._actualizar_panel(selected_groups)

func _update_selection_rect(start: Vector2, end: Vector2):
	var rect = Rect2(start, Vector2.ZERO).expand(end)
	selection_rect_node.visible = true
	selection_rect_node.position = rect.position
	selection_rect_node.size = rect.size

func _update_selection_label():
	var label = get_node("../UI/SelectionLabel")
	label.text = "Seleccionadas: " + str(selected_groups.size())

func _to_world(screen_pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * screen_pos
	
	
func _handle_harvest_click(world_pos: Vector2):
	var trees = get_tree().get_nodes_in_group("trees")
	for tree in trees:
		if world_pos.distance_to(tree.global_position) < 120.0:
			for group in selected_groups:
				group.iniciar_recoleccion(tree, anthill)
			_mostrar_marcador(world_pos)
			harvest_mode = false
			return
			
			
func _mostrar_marcador(pos: Vector2):
	var marker = OrderMarkerScene.instantiate()
	marker.global_position = pos
	get_tree().get_root().get_node("Main").add_child(marker)
