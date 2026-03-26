extends Camera2D

@export var speed: float = 600.0
@export var margin: float = 120.0
@export var map_limit_left: float = 0.0
@export var map_limit_top: float = 0.0
@export var map_limit_right: float = 4096.0
@export var map_limit_bottom: float = 2048.0

@export var zoom_speed: float = 0.1
@export var zoom_min: float = 0.5
@export var zoom_max: float = 3

var _limit_left: float
var _limit_top: float
var _limit_right: float
var _limit_bottom: float

func _ready():
	var half_screen = get_viewport().get_visible_rect().size / 2.0
	_limit_left   = map_limit_left   + half_screen.x
	_limit_top    = map_limit_top    + half_screen.y
	_limit_right  = map_limit_right  - half_screen.x
	_limit_bottom = map_limit_bottom - half_screen.y

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var mouse_screen = get_viewport().get_mouse_position()
			var screen_center = get_viewport().get_visible_rect().size / 2.0
			var offset = mouse_screen - screen_center
			
			var zoom_before = zoom.x
			
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom = clamp(zoom + Vector2.ONE * zoom_speed, Vector2.ONE * zoom_min, Vector2.ONE * zoom_max)
			else:
				zoom = clamp(zoom - Vector2.ONE * zoom_speed, Vector2.ONE * zoom_min, Vector2.ONE * zoom_max)
			
			var zoom_after = zoom.x
			var zoom_factor = (1.0 / zoom_before) - (1.0 / zoom_after)
			position += offset * zoom_factor

			position.x = clamp(position.x, _limit_left, _limit_right)
			position.y = clamp(position.y, _limit_top, _limit_bottom)

func _process(delta):
	var mouse = get_viewport().get_mouse_position()
	var screen = get_viewport().get_visible_rect().size
	var move = Vector2.ZERO

	if mouse.x < margin:
		move.x = -1
	elif mouse.x > screen.x - margin:
		move.x = 1
	if mouse.y < margin:
		move.y = -1
	elif mouse.y > screen.y - margin:
		move.y = 1

	if move != Vector2.ZERO:
		position += move.normalized() * speed * delta
		position.x = clamp(position.x, _limit_left, _limit_right)
		position.y = clamp(position.y, _limit_top, _limit_bottom)
