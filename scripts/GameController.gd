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
@onready var camera_principal: Camera2D = $"../Camera2D"
@onready var piso_label = get_node("../UI/TextsContainer/PisoLabel")
@onready var modo_label = get_node("../UI/TextsContainer/ModoLabel")

var arbol_interior_actual: AntTree = null

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

const PuntoConexionScene = preload("res://scenes/PuntoConexion.tscn")

var modo_conexion: String = ""  # "" | "piso" | "superficie"


var modo_construccion: String = ""  # "" | "tunel" | "camara"
var construccion_inicio: Vector2i = Vector2i.ZERO


func _ready():
	selection_rect_node.visible = false
	call_deferred("_conectar_arboles")
	PisoManager.piso_cambiado.connect(_on_piso_cambiado)
	_actualizar_piso_label(PisoManager.piso_actual)
	_actualizar_modo_label()

func _conectar_arboles():
	for tree in get_tree().get_nodes_in_group("trees"):
		tree.interior.salir_pedido.connect(_cerrar_vista_arbol)

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
	if event.keycode == KEY_ESCAPE and not event.pressed:
		if arbol_interior_actual:
			_cerrar_vista_arbol()
	if event.pressed:
		var n = -1
		if event.keycode >= KEY_KP_0 and event.keycode <= KEY_KP_9:
			n = event.keycode - KEY_KP_0
		elif event.keycode >= KEY_0 and event.keycode <= KEY_9:
			n = event.keycode - KEY_0
		if n >= 0:
			PisoManager.cambiar_a_piso(n)
			if n == 0:
				modo_construccion = ""
	if event.keycode == KEY_T and event.pressed:
		modo_construccion = "tunel" if modo_construccion != "tunel" else ""
		modo_conexion = ""
		_actualizar_modo_label()
	if event.keycode == KEY_C and event.pressed:
		modo_construccion = "camara" if modo_construccion != "camara" else ""
		modo_conexion = ""
		_actualizar_modo_label()
	if event.keycode == KEY_V and event.pressed:
		modo_conexion = "abajo" if modo_conexion != "abajo" else ""
		modo_construccion = ""
		_actualizar_modo_label()
	if event.keycode == KEY_B and event.pressed:
		modo_conexion = "superficie" if modo_conexion != "superficie" else ""
		modo_construccion = ""
		_actualizar_modo_label()
	if event.keycode == KEY_ESCAPE and not event.pressed:
		if arbol_interior_actual:
			_cerrar_vista_arbol()
		elif modo_construccion != "":
			modo_construccion = ""
			_actualizar_modo_label()
		elif modo_conexion != "":
			modo_conexion = ""
			_actualizar_modo_label()

func _handle_mouse_button(event: InputEventMouseButton):
	var world_pos = _to_world(event.position)
	if event.button_index == MOUSE_BUTTON_LEFT:
		if modo_conexion != "" and event.pressed:
			_colocar_punto_conexion(world_pos)
			return
		if modo_construccion != "" and PisoManager.piso_actual != 0:
			var piso = PisoManager.piso_de_nodo(PisoManager.piso_actual)
			if event.pressed:
				construccion_inicio = piso.mundo_a_celda(world_pos)
			else:
				var fin = piso.mundo_a_celda(world_pos)
				if modo_construccion == "camara":
					var origen = Vector2i(min(construccion_inicio.x, fin.x), min(construccion_inicio.y, fin.y))
					var ancho = abs(fin.x - construccion_inicio.x) + 1
					var alto = abs(fin.y - construccion_inicio.y) + 1
					piso.excavar_camara(origen, ancho, alto)
				else:
					_excavar_linea(piso, construccion_inicio, fin)
				selection_rect_node.visible = false
				is_dragging = false
			return
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
	if modo_construccion != "" and PisoManager.piso_actual != 0:
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
	for tree in get_tree().get_nodes_in_group("trees"):
		if world_pos.distance_to(tree.global_position) < 40.0:
			_ver_interior_arbol(tree)
			return
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
	var conexion = _buscar_conexion_cercana(world_pos)
	var count = selected_groups.size()
	for i in count:
		if is_instance_valid(selected_groups[i]):
			if conexion:
				selected_groups[i].mover_a_conexion(conexion)
			else:
				var offset = _formation_offset(i, count)
				selected_groups[i].move_to(world_pos + offset)

func _buscar_conexion_cercana(world_pos: Vector2) -> PuntoConexion:
	var contenedor = anthill if PisoManager.piso_actual == 0 else PisoManager.piso_de_nodo(PisoManager.piso_actual)
	if contenedor == null:
		return null
	for hijo in contenedor.get_children():
		if hijo is PuntoConexion and world_pos.distance_to(hijo.global_position) < 30.0:
			return hijo
	return null

func _call_all_groups(world_pos: Vector2):
	var all_groups = ant_groups_container.get_children()
	var count = all_groups.size()
	for i in count:
		if is_instance_valid(all_groups[i]):
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
		if is_instance_valid(group):
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
	var label = get_node("../UI/TextsContainer/SelectionLabel")
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
	
	
func _ver_interior_arbol(tree):
	if arbol_interior_actual == tree:
		return
	if arbol_interior_actual and is_instance_valid(arbol_interior_actual):
		arbol_interior_actual.interior.ocultar_vista()
	arbol_interior_actual = tree
	tree.interior.mostrar_vista()

func _cerrar_vista_arbol():
	if arbol_interior_actual and is_instance_valid(arbol_interior_actual):
		arbol_interior_actual.interior.ocultar_vista()
	arbol_interior_actual = null
	
	
func _excavar_linea(piso, desde: Vector2i, hasta: Vector2i):
	var x0 = desde.x
	var y0 = desde.y
	var x1 = hasta.x
	var y1 = hasta.y
	var dx = abs(x1 - x0)
	var sx = 1 if x0 < x1 else -1
	var dy = -abs(y1 - y0)
	var sy = 1 if y0 < y1 else -1
	var err = dx + dy
	while true:
		piso.excavar_tunel(Vector2i(x0, y0))
		if x0 == x1 and y0 == y1:
			break
		var e2 = 2 * err
		if e2 >= dy:
			err += dy
			x0 += sx
		if e2 <= dx:
			err += dx
			y0 += sy


func _colocar_punto_conexion(world_pos: Vector2):
	var piso_idx = PisoManager.piso_actual
	if piso_idx == 0:
		return
	var piso = PisoManager.piso_de_nodo(piso_idx)
	if piso == null:
		return
	var celda = piso.mundo_a_celda(world_pos)
	if not piso.celda_valida(celda) or piso.celdas.get(celda, Piso.Celda.VACIO) == Piso.Celda.VACIO:
		return

	if modo_conexion == "superficie":
		_crear_conexion_superficie(piso, piso_idx, celda)
	elif modo_conexion == "abajo":
		_crear_conexion_hacia_abajo(piso, piso_idx, celda)

func _crear_conexion_superficie(piso, piso_idx: int, celda: Vector2i):
	if piso_idx != 1:
		return # la conexión con la superficie solo se puede crear desde el Piso 1
	for hijo in anthill.get_children():
		if hijo is PuntoConexion:
			return # ya existe una conexión con la superficie
	var punto = PuntoConexionScene.instantiate()
	piso.add_child(punto)
	punto.global_position = piso.celda_a_mundo_centro(celda)
	punto.piso = piso_idx
	punto.celda = celda

	var punto_superficie = PuntoConexionScene.instantiate()
	anthill.add_child(punto_superficie)
	punto_superficie.global_position = anthill.global_position
	punto_superficie.piso = 0
	punto_superficie.es_superficie = true

	punto.destino = punto_superficie
	punto_superficie.destino = punto
	punto.actualizar_visual()
	punto_superficie.actualizar_visual()

func _crear_conexion_hacia_abajo(piso, piso_idx: int, celda: Vector2i):
	var piso_abajo = PisoManager.piso_de_nodo(piso_idx + 1)
	if piso_abajo == null:
		return # ese piso todavía no existe en la escena
	if not piso_abajo.celda_valida(celda):
		return

	for hijo in piso.get_children():
		if hijo is PuntoConexion and hijo.celda == celda:
			return # ya hay una conexión en esta celda

	var punto_arriba = PuntoConexionScene.instantiate()
	piso.add_child(punto_arriba)
	punto_arriba.global_position = piso.celda_a_mundo_centro(celda)
	punto_arriba.piso = piso_idx
	punto_arriba.celda = celda

	piso_abajo.excavar_tunel(celda)

	var punto_abajo = PuntoConexionScene.instantiate()
	piso_abajo.add_child(punto_abajo)
	punto_abajo.global_position = piso_abajo.celda_a_mundo_centro(celda)
	punto_abajo.piso = piso_idx + 1
	punto_abajo.celda = celda

	punto_arriba.destino = punto_abajo
	punto_abajo.destino = punto_arriba
	punto_arriba.actualizar_visual()
	punto_abajo.actualizar_visual()


func _on_piso_cambiado(nuevo_piso: int):
	_actualizar_piso_label(nuevo_piso)

func _actualizar_piso_label(piso: int):
	if piso == 0:
		piso_label.text = "Piso: Superficie"
	else:
		piso_label.text = "Piso: %d" % piso

func _actualizar_modo_label():
	if modo_construccion == "tunel":
		modo_label.text = "Modo: Túnel"
	elif modo_construccion == "camara":
		modo_label.text = "Modo: Cámara"
	elif modo_conexion == "abajo":
		modo_label.text = "Modo: Conexión entre pisos"
	elif modo_conexion == "superficie":
		modo_label.text = "Modo: Conexión con la superficie"
	else:
		modo_label.text = "Modo: Ninguno"
