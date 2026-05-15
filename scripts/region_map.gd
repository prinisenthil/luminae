extends Node2D

# ─────────────────────────────────────────
#  Constants
# ─────────────────────────────────────────

const DRAG_THRESHOLD: float = 12.0
const CAMERA_LERP_SPEED: float = 8.0
const SCROLL_DAMPING: float = 0.85

# ─────────────────────────────────────────
#  Exports
# ─────────────────────────────────────────

# Set these in the inspector to clamp camera within the region's map art
@export var camera_min: Vector2 = Vector2(-400.0, -300.0)
@export var camera_max: Vector2 = Vector2(400.0, 300.0)

# ─────────────────────────────────────────
#  Node References
# ─────────────────────────────────────────

@onready var _camera: Camera2D = $Camera2D
#@onready var _player_marker: Node2D = $PlayerMarker
#@onready var _confirm_panel = $ConfirmPanel  # replace type if you have a typed class

# ─────────────────────────────────────────
#  Touch / Scroll State
# ─────────────────────────────────────────

var _touch_active: bool = false
var _touch_start_pos: Vector2 = Vector2.ZERO
var _camera_start_pos: Vector2 = Vector2.ZERO
var _suppress_tap: bool = false
var _drag_velocity: Vector2 = Vector2.ZERO
var _last_drag_pos: Vector2 = Vector2.ZERO

# ─────────────────────────────────────────
#  Lifecycle
# ─────────────────────────────────────────
@export var region_id: String = "region_1"

func _ready() -> void:
	_register_nodes()
	_load_node_states()


func _load_node_states() -> void:
	for child in get_children():
		if child is MapNode:
			var state = GameState.get_node_state(region_id, child.name)
			child.set_state(state)

func _process(delta: float) -> void:
	_apply_scroll_momentum(delta)


# ─────────────────────────────────────────
#  Public API (called by MapNode)
# ─────────────────────────────────────────

func is_tap_suppressed() -> bool:
	return _suppress_tap


# ─────────────────────────────────────────
#  Node Registration
# ─────────────────────────────────────────

func _register_nodes() -> void:
	for child in get_children():
		if child is MapNode:
			child.node_tapped.connect(_on_node_tapped)


# Call this from your game state manager to initialize node states
# for the region when the map loads. Pass a Dictionary of
# { node_name: MapNode.NodeState } pairs.
func apply_node_states(state_map: Dictionary) -> void:
	for child in get_children():
		if child is MapNode:
			var s = state_map.get(child.node_label, MapNode.NodeState.LOCKED)
			child.set_state(s)


# ─────────────────────────────────────────
#  Input — Scroll & Tap Disambiguation
# ─────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)


func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_touch_active = true
		_touch_start_pos = event.position
		_camera_start_pos = _camera.position
		_suppress_tap = false
		_drag_velocity = Vector2.ZERO
		_last_drag_pos = event.position
	else:
		_touch_active = false


func _handle_drag(event: InputEventScreenDrag) -> void:
	if not _touch_active:
		return

	var delta: Vector2 = event.position - _touch_start_pos

	if delta.length() > DRAG_THRESHOLD:
		_suppress_tap = true

	# Track velocity for momentum after finger lifts
	_drag_velocity = event.position - _last_drag_pos
	_last_drag_pos = event.position

	var new_pos: Vector2 = _camera_start_pos - delta
	_camera.position = _clamp_camera(new_pos)


# ─────────────────────────────────────────
#  Scroll Momentum
# ─────────────────────────────────────────

func _apply_scroll_momentum(delta: float) -> void:
	if _touch_active:
		return
	if _drag_velocity.length() < 0.5:
		_drag_velocity = Vector2.ZERO
		return

	_camera.position = _clamp_camera(
		_camera.position - _drag_velocity * delta * 60.0
	)
	_drag_velocity *= SCROLL_DAMPING


# ─────────────────────────────────────────
#  Camera
# ─────────────────────────────────────────

func _clamp_camera(pos: Vector2) -> Vector2:
	return Vector2(
		clamp(pos.x, camera_min.x, camera_max.x),
		clamp(pos.y, camera_min.y, camera_max.y)
	)


# ─────────────────────────────────────────
#  Node Tap Handler
# ─────────────────────────────────────────

func _on_node_tapped(node: MapNode) -> void:
	#_confirm_panel.show_for(node)
	GameState.current_region = region_id
	GameState.current_node = node.name
	GameState.change_scene("battle")


# ─────────────────────────────────────────
#  Player Marker
# ─────────────────────────────────────────

# Call this after a node is completed to animate the marker
# moving to the new node's position.
#func move_marker_to(node: MapNode) -> void:
#	var tween := create_tween()
#	tween.tween_property(
#		_player_marker,
#		"position",
#		node.position,
#		0.4
#	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
