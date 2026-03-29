class_name AntGroup
extends CharacterBody2D

const SPEED = 120.0
const ARRIVAL_THRESHOLD = 8.0

enum Estado { ESPERANDO, PATRULLANDO }

@export var color_normal: Color = Color(1, 1, 1, 1)
@export var color_selected: Color = Color(1, 1, 1, 1)

var selected: bool = false
var moving: bool = false
var estado_actual: Estado = Estado.ESPERANDO

var patrol_points: Array = []
var patrol_index: int = 0
var patrol_direction: int = 1

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var selection_ring: Node2D = $SelectionRing

func _ready():
	await get_tree().physics_frame
	nav_agent.path_desired_distance = ARRIVAL_THRESHOLD
	nav_agent.target_desired_distance = ARRIVAL_THRESHOLD
	set_selected(false)
	sprite.play("walk")

func _physics_process(delta):
	match estado_actual:
		Estado.ESPERANDO:
			_tick_esperando()
		Estado.PATRULLANDO:
			_tick_patrullando()

func _tick_esperando():
	if moving:
		if nav_agent.is_navigation_finished():
			moving = false
			sprite.stop()
			return
		var next = nav_agent.get_next_path_position()
		var direction = (next - global_position).normalized()
		velocity = direction * SPEED
		move_and_slide()
		if direction != Vector2.ZERO:
			sprite.rotation = direction.angle() - PI / 2
			sprite.play("walk")
	else:
		sprite.stop()

func _tick_patrullando():
	if patrol_points.is_empty():
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

func set_patrol(points: Array):
	if points.is_empty():
		return
	patrol_points = points
	patrol_index = 0
	estado_actual = Estado.PATRULLANDO
	nav_agent.target_position = patrol_points[0]

func set_selected(value: bool):
	selected = value
	sprite.modulate = Color(1, 1, 1, 1)
	selection_ring.set_selected(value)
