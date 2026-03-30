class_name AntGroup
extends CharacterBody2D

const SPEED = 120.0
const ARRIVAL_THRESHOLD = 8.0

enum Estado { ESPERANDO, PATRULLANDO }

const COLOR_ESPERANDO  = Color(1, 1, 0, 0.9)      # amarillo
const COLOR_PATRULLANDO = Color(0, 0.6, 1, 0.9)   # azul

@export var color_normal: Color = Color(1, 1, 1, 1)
@export var color_selected: Color = Color(1, 1, 1, 1)

var selected: bool = false
var moving: bool = false
var estado_actual: Estado = Estado.ESPERANDO

var patrol_points: Array = []
var patrol_index: int = 0
var patrol_direction: int = 1

@export var stats: AntStats

var integrantes_actuales: int = 0
var daño_acumulado: float = 0.0
var carga_actual: float = 0.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var selection_ring: Node2D = $SelectionRing

func _ready():
	await get_tree().physics_frame
	nav_agent.path_desired_distance = ARRIVAL_THRESHOLD
	nav_agent.target_desired_distance = ARRIVAL_THRESHOLD
	set_selected(false)
	sprite.play("walk")
	_actualizar_color_estado()
	if stats:
		integrantes_actuales = stats.integrantes_max

func _physics_process(delta):
	match estado_actual:
		Estado.ESPERANDO:
			_tick_esperando()
		Estado.PATRULLANDO:
			_tick_patrullando()

func _actualizar_color_estado():
	match estado_actual:
		Estado.ESPERANDO:
			selection_ring.set_estado_color(COLOR_ESPERANDO)
		Estado.PATRULLANDO:
			selection_ring.set_estado_color(COLOR_PATRULLANDO)

func _tick_esperando():
	if moving:
		if nav_agent.is_navigation_finished():
			moving = false
			sprite.stop()
			return
		var next = nav_agent.get_next_path_position()
		var direction = (next - global_position).normalized()
		velocity = direction * stats.velocidad if stats else direction * 100.0
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
		velocity = direction * stats.velocidad if stats else direction * 100.0
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
	velocity = direction * SPEED
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

func set_patrol(points: Array):
	if points.is_empty():
		return
	patrol_points = points
	patrol_index = 0
	patrol_direction = 1
	estado_actual = Estado.PATRULLANDO
	nav_agent.target_position = patrol_points[0]
	_actualizar_color_estado()

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
