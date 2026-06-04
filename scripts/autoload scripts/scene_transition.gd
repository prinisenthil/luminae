extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var color_rect = $ColorRect

func _ready():
	color_rect.modulate.a = 0.0
	# Hides the rect from mouse detection completely on startup
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE 

func change_scene(target_scene_path: String) -> void:
	# 1. Block clicks right as the fade starts
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	animation_player.play("fade")
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file(target_scene_path)
	
	animation_player.play_backwards("fade")
	await animation_player.animation_finished
	
	# 2. Stop blocking clicks once the screen is clear again
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
