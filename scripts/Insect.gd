class_name Insect
extends CharacterBody2D

const SPEED = 80.0

@export var vida_max: float = 1000
@export var daño: float = 8.0
@export var velocidad_ataque: float = 1.5

var vida_actual: float = 0.0
var timer_ataque: float = 0.0
var target: Node2D = null
var estado: String = "deambulando"
var timer_deambular: float = 0.0
var punto_destino: Vector2 = Vector2.ZERO

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	await get_tree().physics_frame
	vida_actual = vida_max
	_nuevo_punto_deambular()
	sprite.play("walk")

	
func _physics_process(delta):
	timer_ataque += delta
	match estado:
		"deambulando":
			_tick_deambulando(delta)
		"combate":
			_tick_combate(delta)

func _tick_deambulando(delta):
	timer_deambular += delta
	if nav_agent.is_navigation_finished() or timer_deambular > 5.0:
		timer_deambular = 0.0
		_nuevo_punto_deambular()
		return
	var next = nav_agent.get_next_path_position()
	var direction = (next - global_position).normalized()
	velocity = direction * SPEED
	move_and_slide()
	if direction != Vector2.ZERO:
		sprite.rotation = direction.angle() - PI / 2

func _tick_combate(delta):
	if target == null or not is_instance_valid(target):
		estado = "deambulando"
		target = null
		_nuevo_punto_deambular()
		return
	var distancia = global_position.distance_to(target.global_position)
	if distancia > 400.0:
		estado = "deambulando"
		target = null
		_nuevo_punto_deambular()
		return
	if distancia > 30.0:
		nav_agent.target_position = target.global_position
		var next = nav_agent.get_next_path_position()
		var direction = (next - global_position).normalized()
		velocity = direction * SPEED
		move_and_slide()
		if direction != Vector2.ZERO:
			sprite.rotation = direction.angle() - PI / 2
	else:
		velocity = Vector2.ZERO
		if timer_ataque >= velocidad_ataque:
			timer_ataque = 0.0
			_atacar()

func _atacar():
	if target == null or not is_instance_valid(target):
		return
	if target.has_method("recibir_daño"):
		target.recibir_daño(daño)

func recibir_daño(cantidad: float):
	vida_actual -= cantidad
	if vida_actual <= 0:
		queue_free()

func set_target(new_target: Node2D):
	target = new_target
	estado = "combate"

func _nuevo_punto_deambular():
	var offset = Vector2(
		randf_range(-300, 300),
		randf_range(-300, 300)
	)
	punto_destino = global_position + offset
	nav_agent.target_position = punto_destino
