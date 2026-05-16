extends Node2D
class_name Luminae

@export var luminae_data: LuminaeData
@export var player: bool
@export var level: int = 5

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var tap_area: Area2D = $Area2D
@onready var hp_bar: TextureProgressBar = $HPBar
@onready var attack_origin: Marker2D = $AttackOrigin
@onready var impact_point: Marker2D = $ImpactPoint
@onready var idle_anim: SpriteFrames = luminae_data.idle
@onready var attack_anim: SpriteFrames = luminae_data.attack

# Calculated stats based on level and base values
var attack: int
var defense: int
var max_health: int
var health: int
var spirit_orbs

signal tapped

func _ready():
	if not player:
		sprite.flip_h = false
	else:
		tap_area.monitoring = false
	sprite.sprite_frames = idle_anim
	sprite.play()
	set_stats()

static func create(luminae_data: LuminaeData, level: int, player: bool) -> Luminae:
	var new_luminae := Luminae.new()
	new_luminae.luminae_data = luminae_data
	new_luminae.level = level
	new_luminae.player = player
	return new_luminae

func play_idle():
	sprite.sprite_frames = idle_anim
	sprite.play()

func play_attack():
	sprite.sprite_frames = attack_anim
	sprite.play()
	await sprite.animation_finished

func _on_tap(viewport, event, shape_idx) -> void:
	if event is InputEventScreenTouch and event.pressed:
		tapped.emit()

# Recalculates all derived stats based on level and base stats
func set_stats():
	attack = calc_stat(luminae_data.base_attack)
	defense = calc_stat(luminae_data.base_defense)
	max_health = calc_hp()
	hp_bar.setup(max_health)
	health = max_health

# Calculates attack, defense, speed etc
func calc_stat(base_stat: int) -> int:
	return int(base_stat * (1.0 + (level - 1) * 0.1))

# Calculates max HP
func calc_hp() -> int:
	return int(luminae_data.base_health * (1.0 + (level - 1) * 0.15))

func update_health(dmg):
	health = max(0, health - dmg)
	hp_bar.take_damage(dmg)
