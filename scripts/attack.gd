extends Control
class_name Attack
@export var move: MoveData
@export var available: bool = false

# State textures — assign in inspector or at load time
@export var texture_available: Texture2D
@export var texture_locked: Texture2D

@onready var btn = $Button
@onready var _label = $Label

func setup(this_move):
	move = this_move
	$Label.text = str(move.energy_cost)

func set_availability(new_state: bool) -> void:
	available = new_state
	_apply_state()
	btn.disabled = not new_state

func _apply_state() -> void:
	if available:
		if texture_available:
			btn.texture = texture_available
		btn.modulate = Color.WHITE
		_label.modulate = Color.WHITE
	else:
		if texture_locked:
			btn.texture = texture_locked
		btn.modulate = Color(1.0, 1.0, 1.0, 0.4)
		_label.modulate = Color(1.0, 1.0, 1.0, 0.4)
