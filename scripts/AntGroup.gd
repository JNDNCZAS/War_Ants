class_name AntGroup
extends CharacterBody2D

#==================================================
# CONSTANTES
#==================================================

const SPEED = 120.0
const ARRIVAL_THRESHOLD = 8.0

const COLOR_ESPERANDO     = Color(1, 1, 0, 0.9)
const COLOR_PATRULLANDO   = Color(0, 0.6, 1, 0.9)
const COLOR_RECOLECTANDO  = Color(0, 1, 0.2, 0.9)
const COLOR_TRANSPORTANDO = Color(1, 0.5, 0, 0.9)
const COLOR_COMBATE       = Color(1, 0, 0, 0.9)

#==================================================
# ENUMS
#==================================================

enum Estado {ESPERANDO, PATRULLANDO, RECOLECTANDO, TRANSPORTANDO, COMBATE}

#==================================================
# VARIABLES EXPORTADAS
#==================================================

@export var color_normal: Color = Color(1, 1, 1, 1)
@export var color_selected: Color = Color(1, 1, 1, 1)
@export var stats: AntStats

#==================================================
# REFERENCIAS A NODOS
#==================================================

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var selection_ring: Node2D = $SelectionRing
@onready var detection_area: Area2D = $DetectionArea
@onready var detection_shape: CollisionShape2D = $DetectionArea/DetectionShape
#==================================================
# ESTADO GENERAL
#==================================================

var estado_actual: Estado = Estado.ESPERANDO
var selected: bool = false
var moving: bool = false

#==================================================
# PATRULLA
#==================================================

var patrol_points: Array = []
var patrol_index: int = 0
var patrol_direction: int = 1

#==================================================
# RECOLECCIÓN Y TRANSPORTE
#==================================================

var target_tree = null
var target_anthill = null
var carga=false

var hojas_cargadas: float = 0.0
var carga_actual: float = 0.0

var timer_recoleccion: float = 0.0
var timer_descarga: float = 0.0

#==================================================
# VIDA Y COMBATE
#==================================================

var integrantes_actuales: int = 0
var daño_acumulado: float = 0.0

#=================================================
#COMBATE
#=================================================

var target_insect = null
var estado_anterior: int = -1
var timer_ataque: float = 0.0

func _ready():
	await get_tree().physics_frame
	nav_agent.path_desired_distance = ARRIVAL_THRESHOLD
	nav_agent.target_desired_distance = ARRIVAL_THRESHOLD
	set_selected(false)
	sprite.play("walk")
	_actualizar_color_estado()
	_actualizar_radio_deteccion()
	if stats:
		integrantes_actuales = stats.integrantes_max
		
func _physics_process(delta):
	var overlapping = detection_area.get_overlapping_bodies()
	if overlapping.size() > 0:
		print("cuerpos en area: ", overlapping.size())
	match estado_actual:
		Estado.ESPERANDO:
			_tick_esperando()
		Estado.PATRULLANDO:
			_tick_patrullando()
		Estado.RECOLECTANDO:
			_tick_recolectando(delta)
		Estado.TRANSPORTANDO:
			_tick_transportando(delta)
		Estado.COMBATE:
			_tick_combate(delta)

func _actualizar_color_estado():
	match estado_actual:
		Estado.ESPERANDO:
			selection_ring.set_estado_color(COLOR_ESPERANDO)
		Estado.PATRULLANDO:
			selection_ring.set_estado_color(COLOR_PATRULLANDO)
		Estado.RECOLECTANDO:
			selection_ring.set_estado_color(COLOR_RECOLECTANDO)
		Estado.TRANSPORTANDO:
			selection_ring.set_estado_color(COLOR_TRANSPORTANDO)
		Estado.COMBATE:
			selection_ring.set_estado_color(COLOR_COMBATE)

func _tick_esperando():
	if moving:
		if nav_agent.is_navigation_finished():
			moving = false
			sprite.stop()
			return
		var next = nav_agent.get_next_path_position()
		var direction = (next - global_position).normalized()
		velocity = direction * _velocidad_actual()
		move_and_slide()
		if direction != Vector2.ZERO:
			sprite.rotation = direction.angle() - PI / 2
			sprite.play("walk")
	else:
		sprite.stop()

func _tick_patrullando():
	if patrol_points.is_empty():
		return
	if patrol_points.size() == 1:
		if nav_agent.is_navigation_finished():
			sprite.stop()
			return
		var next = nav_agent.get_next_path_position()
		var direction = (next - global_position).normalized()
		velocity = direction * _velocidad_actual()
		move_and_slide()
		if direction != Vector2.ZERO:
			sprite.rotation = direction.angle() - PI / 2
			sprite.play("walk")
		return
	if nav_agent.is_navigation_finished():
		patrol_index += patrol_direction
		if patrol_index >= patrol_points.size():
			patrol_direction = -1
			patrol_index = patrol_points.size() - 2
		elif patrol_index < 0:
			patrol_direction = 1
			patrol_index = 1
		nav_agent.target_position = patrol_points[patrol_index]
	var next = nav_agent.get_next_path_position()
	var direction = (next - global_position).normalized()
	velocity = direction * (stats.velocidad if stats else SPEED)
	move_and_slide()
	if direction != Vector2.ZERO:
		sprite.rotation = direction.angle() - PI / 2
		sprite.play("walk")

func move_to(pos: Vector2):
	estado_actual = Estado.ESPERANDO
	patrol_points.clear()
	moving = true
	nav_agent.target_position = pos
	_actualizar_color_estado()
	_actualizar_radio_deteccion()

func set_patrol(points: Array):
	if points.is_empty():
		return
	patrol_points = points
	patrol_index = 0
	patrol_direction = 1
	estado_actual = Estado.PATRULLANDO
	nav_agent.target_position = patrol_points[0]
	_actualizar_color_estado()
	_actualizar_radio_deteccion()

func set_selected(value: bool):
	selected = value
	sprite.modulate = Color(1, 1, 1, 1)
	selection_ring.set_selected(value)
	

func recibir_daño(cantidad: float):
	if not stats:
		return
	daño_acumulado += cantidad * stats.defensa
	while daño_acumulado >= stats.vida_por_hormiga:
		daño_acumulado -= stats.vida_por_hormiga
		integrantes_actuales -= 1
		if integrantes_actuales <= 0:
			integrantes_actuales = 0
			queue_free()
			return

func _tick_recolectando(delta):
	if carga==false:###
		if target_tree == null:
			estado_actual = Estado.ESPERANDO
			_actualizar_color_estado()
			return
		if not nav_agent.is_navigation_finished():
			var next = nav_agent.get_next_path_position()
			var direction = (next - global_position).normalized()
			velocity = direction * _velocidad_actual()
			move_and_slide()
			if direction != Vector2.ZERO:
				sprite.rotation = direction.angle() - PI / 2
				sprite.play("walk")
		else:
			sprite.stop()
			timer_recoleccion += delta
			if timer_recoleccion >= stats.tiempo_recoleccion:
				timer_recoleccion = 0.0
				if target_tree == null or not is_instance_valid(target_tree):
					estado_actual = Estado.ESPERANDO
					_actualizar_color_estado()
					return
				var cantidad = target_tree.reducir_hojas(stats.capacidad_carga)
				if cantidad <= 0:
					estado_actual = Estado.ESPERANDO
					_actualizar_color_estado()
					return
				hojas_cargadas = cantidad
				carga=true###
				_iniciar_transporte()
	if carga==true:###
		_iniciar_transporte()###
		
func _tick_transportando(delta):
	if target_anthill == null:
		estado_actual = Estado.ESPERANDO
		_actualizar_color_estado()
		return
	if not nav_agent.is_navigation_finished():
		var next = nav_agent.get_next_path_position()
		var direction = (next - global_position).normalized()
		velocity = direction * _velocidad_actual()
		move_and_slide()
		if direction != Vector2.ZERO:
			sprite.rotation = direction.angle() - PI / 2
			sprite.play("walk")
	else:
		sprite.stop()
		timer_descarga += delta
		if timer_descarga >= stats.tiempo_descarga:
			timer_descarga = 0.0
			target_anthill.agregar_hojas(hojas_cargadas)
			hojas_cargadas = 0.0
			carga=false
			_iniciar_recoleccion()

func _tick_combate(delta):
	if target_insect == null or not is_instance_valid(target_insect):
		_terminar_combate()
		return
	timer_ataque += delta
	var distancia = global_position.distance_to(target_insect.global_position)
	if distancia > stats.radio_deteccion_normal * 1.5:
		_terminar_combate()
		return
	if distancia > 30.0:
		nav_agent.target_position = target_insect.global_position
		var next = nav_agent.get_next_path_position()
		var direction = (next - global_position).normalized()
		velocity = direction * _velocidad_actual()
		move_and_slide()
		if direction != Vector2.ZERO:
			sprite.rotation = direction.angle() - PI / 2
			sprite.play("walk")
	else:
		velocity = Vector2.ZERO
		sprite.stop()
		if timer_ataque >= stats.velocidad_ataque:
			timer_ataque = 0.0
			target_insect.recibir_daño(stats.daño * integrantes_actuales * 0.1)


func _iniciar_recoleccion():
	if target_tree == null:
		return
	estado_actual = Estado.RECOLECTANDO
	nav_agent.target_desired_distance = 2
	nav_agent.target_position = target_tree.global_position
	_actualizar_color_estado()

func _iniciar_transporte():
	if target_anthill == null:
		return
	estado_actual = Estado.TRANSPORTANDO
	nav_agent.target_desired_distance = ARRIVAL_THRESHOLD
	nav_agent.target_position = target_anthill.global_position
	#carga=false
	_actualizar_color_estado()

func iniciar_recoleccion(tree, anthill):
	target_tree = tree
	target_anthill = anthill
	_iniciar_recoleccion()


func _velocidad_actual() -> float:
	if carga and stats:
		return stats.velocidad * stats.reduccion_velocidad_carga
	return stats.velocidad if stats else SPEED



func _actualizar_radio_deteccion():
	if not stats:
		return
	var shape = CircleShape2D.new()
	if estado_actual == Estado.PATRULLANDO:
		shape.radius = stats.radio_deteccion_patrulla
	else:
		shape.radius = stats.radio_deteccion_normal
	detection_shape.shape = shape
	
func _on_body_entered(body):
	print("BODY ENTERED: ", body.name, " clase: ", body.get_class())
	if body is Insect and estado_actual != Estado.COMBATE:
		_iniciar_combate(body)
		
		
func _iniciar_combate(insect):
	estado_anterior = estado_actual
	target_insect = insect
	insect.set_target(self)
	estado_actual = Estado.COMBATE
	nav_agent.target_desired_distance = ARRIVAL_THRESHOLD
	_actualizar_color_estado()
	call_deferred("_actualizar_radio_deteccion")  # ← cambia esto
	
	
func _terminar_combate():
	target_insect = null
	estado_actual = estado_anterior if estado_anterior != -1 else Estado.ESPERANDO
	estado_anterior = -1
	timer_ataque = 0.0
	_actualizar_color_estado()
	call_deferred("_actualizar_radio_deteccion")  # ← cambia esto
	
func _on_body_exited(body):
	print("BODY EXITED: ", body.name)
