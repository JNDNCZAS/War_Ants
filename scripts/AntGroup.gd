class_name AntGroup
extends CharacterBody2D

@export var SPEED = 200.0
const ARRIVAL_THRESHOLD = 8.0

@export var color_normal: Color = Color(0.18, 0.49, 0.2)
@export var color_selected: Color = Color(0.3, 0.8, 0.3)

var selected: bool = false
var moving: bool = false

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var sprite: ColorRect = $Sprite
@onready var selection_ring: Node2D = $SelectionRing

func _ready():
	await get_tree().physics_frame
	nav_agent.path_desired_distance = ARRIVAL_THRESHOLD
	nav_agent.target_desired_distance = ARRIVAL_THRESHOLD
	set_selected(false)

func _physics_process(delta):
	if not moving:
		return
	if nav_agent.is_navigation_finished():
		moving = false
		return
	var next = nav_agent.get_next_path_position()
	velocity = (next - global_position).normalized() * SPEED
	move_and_slide()

func move_to(pos: Vector2):
	moving = true
	nav_agent.target_position = pos

func set_selected(value: bool):
	selected = value
	selection_ring.visible = value
	sprite.color = color_selected if value else color_normal
