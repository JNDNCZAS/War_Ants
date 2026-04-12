extends PanelContainer

@onready var texture_rect: TextureRect = $TextureRect
@onready var progress_bar: ProgressBar = $ProgressBar

var stats: AntStats = null
var indice: int = 0

func setup(ant_stats: AntStats, idx: int):
	stats = ant_stats
	indice = idx
	if stats.sprite_frames:
		var frame = stats.sprite_frames.get_frame_texture("walk", 0)
		texture_rect.texture = frame

func actualizar_progreso(valor: float):
	progress_bar.value = valor

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("clic en QueueCard indice: ", indice)
			SpawnQueue.cancelar(indice)
