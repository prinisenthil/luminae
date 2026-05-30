extends Area2D
class_name MapNode

#  Enums & Constants

enum NodeState { LOCKED, AVAILABLE, COMPLETED }

enum NodeType {
	BATTLE,
	MURK,
	DISCOVERY,
	EVENT,
	LIBERATION,
	PELL,
	POST_ETERNAL,
	THRONE
}

#  Exports

@export var node_label: String = ""
@export var node_type: NodeType = NodeType.BATTLE
@export var state: NodeState = NodeState.LOCKED

# State textures — assign in inspector or via RegionMap at load time
@export var texture_available: Texture2D
@export var texture_completed: Texture2D
@export var texture_locked: Texture2D

# Available Luminae and spawn rates
@export var luminae_entries: Array[LuminaeEntry] = []

# Post-Eternal shimmer — assign if this is a POST_ETERNAL node
@export var is_post_eternal: bool = false

#  Signals

signal node_tapped(node: MapNode)

#  Node References

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _label: Label = $Label
#@onready var _shimmer: GPUParticles2D = $Shimmer  # nullable — only on post-eternal nodes


func _ready() -> void:
	_apply_state()
#	_apply_shimmer()
	_label.text = node_label


func set_state(new_state: NodeState) -> void:
	state = new_state
	_apply_state()


func get_display_name() -> String:
	return node_label


func get_node_type() -> NodeType:
	return node_type


#  Input

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if state == NodeState.LOCKED:
		return
	if not event is InputEventScreenTouch:
		return
	if not event.pressed:
		return

	# Ask the parent map whether this touch was actually a drag
	var map := get_parent()
	if map and map.has_method("is_tap_suppressed") and map.is_tap_suppressed():
		return

	node_tapped.emit(self)

#  Private


func _apply_state() -> void:
	match state:
		NodeState.AVAILABLE:
			if texture_available:
				_sprite.texture = texture_available
			_sprite.modulate = Color.WHITE
			_label.modulate = Color.WHITE
		NodeState.COMPLETED:
			if texture_completed:
				_sprite.texture = texture_completed
			_sprite.modulate = Color.WHITE
			_label.modulate = Color.WHITE
		NodeState.LOCKED:
			if texture_locked:
				_sprite.texture = texture_locked
			_sprite.modulate = Color(1.0, 1.0, 1.0, 0.4)
			_label.modulate = Color(1.0, 1.0, 1.0, 0.4)

func spawn_luminae():
	if luminae_entries.is_empty():
		push_error("No luminae entries on node: " + node_label)
		return null
	
	var total_weight: int = 0
	for entry in luminae_entries:
		total_weight += entry.spawn_rate
	
	var roll := randi() % total_weight
	var cumulative:= 0
	var chosen: LuminaeEntry
	
	for entry in luminae_entries:
		cumulative += entry.spawn_rate
		if roll < cumulative:
			chosen = entry
			break
	
	var level := randi_range(chosen.low_level, chosen.upper_level)
	
	return Luminae.create_luminae(chosen.Luminae, level, false)

#func _apply_shimmer() -> void:
#	if not _shimmer:
#		return
	# Shimmer runs on post-eternal nodes regardless of whether
	# the Wanderer is present — it marks restoration, not the encounter
#	_shimmer.emitting = is_post_eternal
