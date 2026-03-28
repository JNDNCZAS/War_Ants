class_name AntGroup
extends CharacterBody2D

const SPEED = 120.0
const ARRIVAL_THRESHOLD = 8.0

@export var color_normal: Color = Color(1, 1, 1, 1)
@export var color_selected: Color = Color(0.6, 1.0, 0.6, 1.0)

var selected: bool = false
var moving: bool = false

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var selection_ring: Node2D = $SelectionRing

func _ready():
	await get_tree().physics_frame
	nav_agent.path_desired_distance = ARRIVAL_THRESHOLD
	nav_agent.target_desired_distance = ARRIVAL_THRESHOLD
	sprite.offset = Vector2(0,0)
	set_selected(false)
	sprite.play("walk")

func _physics_process(delta):
	if not moving:
		sprite.stop()
		return
	if nav_agent.is_navigation_finished():
		moving = false
		sprite.stop()
		return

	var next = nav_agent.get_next_path_position()
	var direction = (next - global_position).normalized()
	velocity = direction * SPEED
	move_and_slide()

	# apunta el sprite en la dirección de movimiento
	if direction != Vector2.ZERO:
		sprite.rotation = direction.angle() - PI/2
		sprite.play("walk")

func move_to(pos: Vector2):
	moving = true
	nav_agent.target_position = pos

func set_selected(value: bool):
	selected = value
	selection_ring.visible = value
	sprite.modulate = color_selected if value else color_normal
