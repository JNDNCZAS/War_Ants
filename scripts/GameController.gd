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



@onready var panel_tipos: Control = $"../UI/PanelTipos"
@onready var boton_tipos: Button = $"../UI/BotonTipos"

var tipo_seleccionado_para_pintar: String = "vacio"

@onready var tooltip_camara: Label = $"../UI/TooltipCamara"

func _ready():
	selection_rect_node.visible = false
	call_deferred("_conectar_arboles")
	PisoManager.piso_cambiado.connect(_on_piso_cambiado)
	_actualizar_piso_label(PisoManager.piso_actual)
	boton_tipos.pressed.connect(_alternar_modo_tipos)
	_construir_panel_tipos()
	panel_tipos.visible = false
	_actualizar_modo_label()

func _conectar_arboles():
	for tree in get_tree().get_nodes_in_group("trees"):
		tree.interior.salir_pedido.connect(_cerrar_vista_arbol)

func _unhandled_input(event):
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
		PisoManager.desactivar_modo_tipos()
		panel_tipos.visible = false
		tooltip_camara.visible = false
		_actualizar_modo_label()
	if event.keycode == KEY_C and event.pressed:
		modo_construccion = "camara" if modo_construccion != "camara" else ""
		modo_conexion = ""
		PisoManager.desactivar_modo_tipos()
		panel_tipos.visible = false
		tooltip_camara.visible = false
		_actualizar_modo_label()
	if event.keycode == KEY_V and event.pressed:
		modo_conexion = "abajo" if modo_conexion != "abajo" else ""
		modo_construccion = ""
		PisoManager.desactivar_modo_tipos()
		panel_tipos.visible = false
		tooltip_camara.visible = false
		_actualizar_modo_label()
	if event.keycode == KEY_B and event.pressed:
		modo_conexion = "superficie" if modo_conexion != "superficie" else ""
		modo_construccion = ""
		PisoManager.desactivar_modo_tipos()
		panel_tipos.visible = false
		tooltip_camara.visible = false
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
		elif PisoManager.modo_tipos_activo:
			PisoManager.desactivar_modo_tipos()
			panel_tipos.visible = false
			tooltip_camara.visible = false
			_actualizar_modo_label()
	if event.keycode == KEY_E and event.pressed:
		modo_construccion = "eliminar" if modo_construccion != "eliminar" else ""
		modo_conexion = ""
		PisoManager.desactivar_modo_tipos()
		panel_tipos.visible = false
		tooltip_camara.visible = false
		_actualizar_modo_label()

func _handle_mouse_button(event: InputEventMouseButton):
	var world_pos = _to_world(event.position)
	if event.button_index == MOUSE_BUTTON_LEFT:
		if PisoManager.modo_tipos_activo and event.pressed and PisoManager.piso_actual != 0:
			_pintar_tipo_camara(world_pos)
			return
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
				elif modo_construccion == "eliminar":
					piso.eliminar_en(fin)
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



func _handle_mouse_motion(event: InputEventMouseMotion):
	if PisoManager.modo_tipos_activo:
		_actualizar_tooltip_camara(event.position)
	elif tooltip_camara.visible:
		tooltip_camara.visible = false

	if modo_construccion != "" or modo_conexion != "" or PisoManager.modo_tipos_activo:
		return
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


func _obtener_o_crear_punto_conexion(piso, piso_idx: int, celda: Vector2i) -> PuntoConexion:
	for hijo in piso.get_children():
		if hijo is PuntoConexion and hijo.celda == celda:
			return hijo
	var punto = PuntoConexionScene.instantiate()
	piso.add_child(punto)
	punto.global_position = piso.celda_a_mundo_centro(celda)
	punto.piso = piso_idx
	punto.celda = celda
	return punto

func _crear_conexion_superficie(piso, piso_idx: int, celda: Vector2i):
	if piso_idx != 1:
		return

	var punto = _obtener_o_crear_punto_conexion(piso, piso_idx, celda)
	if punto.destino:
		return # ya hay una conexión activa en esta celda

	var punto_superficie: PuntoConexion = null
	for hijo in anthill.get_children():
		if hijo is PuntoConexion:
			punto_superficie = hijo
			break

	if punto_superficie == null:
		punto_superficie = PuntoConexionScene.instantiate()
		anthill.add_child(punto_superficie)
		punto_superficie.global_position = anthill.global_position
		punto_superficie.piso = 0
		punto_superficie.es_superficie = true
	elif punto_superficie.destino:
		return # ya existe una conexión con la superficie activa en otra celda

	punto.destino = punto_superficie
	punto_superficie.destino = punto
	punto.actualizar_visual()
	punto_superficie.actualizar_visual()
	_forzar_tipo_conexion(piso, celda)

func _crear_conexion_hacia_abajo(piso, piso_idx: int, celda: Vector2i):
	var piso_abajo = PisoManager.piso_de_nodo(piso_idx + 1)
	if piso_abajo == null:
		return
	if not piso_abajo.celda_valida(celda):
		return

	var punto_arriba = _obtener_o_crear_punto_conexion(piso, piso_idx, celda)
	if punto_arriba.destino:
		return # ya hay una conexión activa en esta celda

	if piso_abajo.camara_en_celda(celda) == null:
		if piso_abajo.excavar_camara(celda, 1, 1) == null:
			return # esa celda choca con otra cámara distinta, no se puede

	var punto_abajo = _obtener_o_crear_punto_conexion(piso_abajo, piso_idx + 1, celda)
	punto_arriba.destino = punto_abajo
	punto_abajo.destino = punto_arriba
	punto_arriba.actualizar_visual()
	punto_abajo.actualizar_visual()
	_forzar_tipo_conexion(piso, celda)
	_forzar_tipo_conexion(piso_abajo, celda)


func _on_piso_cambiado(nuevo_piso: int):
	_actualizar_piso_label(nuevo_piso)

func _actualizar_piso_label(piso: int):
	if piso == 0:
		piso_label.text = "Piso: Superficie"
	else:
		piso_label.text = "Piso: %d" % piso

func _actualizar_modo_label():
	if PisoManager.modo_tipos_activo:
		modo_label.text = "Modo: Tipos de cámara (pintando: %s)" % TiposCamara.nombre_de(tipo_seleccionado_para_pintar)
	elif modo_construccion == "tunel":
		modo_label.text = "Modo: Túnel"
	elif modo_construccion == "camara":
		modo_label.text = "Modo: Cámara"
	elif modo_conexion == "abajo":
		modo_label.text = "Modo: Conexión entre pisos"
	elif modo_conexion == "superficie":
		modo_label.text = "Modo: Conexión con la superficie"
	elif modo_construccion == "eliminar":
		modo_label.text = "Modo: Eliminar"
	else:
		modo_label.text = "Modo: Ninguno"

func _construir_panel_tipos():
	for tipo in TiposCamara.lista_tipos():
		var boton = Button.new()
		boton.text = TiposCamara.nombre_de(tipo)
		boton.pressed.connect(func():
			tipo_seleccionado_para_pintar = tipo
			_actualizar_modo_label()
		)
		panel_tipos.add_child(boton)

func _alternar_modo_tipos():
	PisoManager.alternar_modo_tipos()
	if PisoManager.modo_tipos_activo:
		modo_construccion = ""
		modo_conexion = ""
	panel_tipos.visible = PisoManager.modo_tipos_activo
	_actualizar_modo_label()
	
	
func _pintar_tipo_camara(world_pos: Vector2):
	var piso = PisoManager.piso_de_nodo(PisoManager.piso_actual)
	if piso == null:
		return
	var celda = piso.mundo_a_celda(world_pos)
	var camara = piso.camara_en_celda(celda)
	if camara == null or camara.tipo_bloqueado:
		return
	camara.tipo = tipo_seleccionado_para_pintar
	piso.dibujo.queue_redraw()

func _actualizar_tooltip_camara(pos_pantalla: Vector2):
	if PisoManager.piso_actual == 0:
		tooltip_camara.visible = false
		return
	var piso = PisoManager.piso_de_nodo(PisoManager.piso_actual)
	if piso == null:
		tooltip_camara.visible = false
		return
	var world_pos = _to_world(pos_pantalla)
	var celda = piso.mundo_a_celda(world_pos)
	var camara = piso.camara_en_celda(celda)
	if camara == null:
		tooltip_camara.visible = false
		return
	tooltip_camara.text = "%s — %dx%d (%d celdas)" % [
		TiposCamara.nombre_de(camara.tipo), camara.ancho, camara.alto, camara.total_celdas()
	]
	tooltip_camara.position = pos_pantalla + Vector2(16, 16)
	tooltip_camara.visible = true
	
	
	
func _forzar_tipo_conexion(piso, celda: Vector2i):
	var camara = piso.camara_en_celda(celda)
	if camara:
		camara.tipo = "conexion"
		camara.tipo_bloqueado = true
		piso.dibujo.queue_redraw()
