extends Node2D
class_name Luminae

@export var luminae_data: LuminaeData
@export var player: bool

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
var level: int
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

func play_idle():
	sprite.sprite_frames = idle_anim
	sprite.play()

func play_attack():
	sprite.sprite_frames = attack_anim
	sprite.play()
	await sprite.animation_finished

func _on_tap(viewport, event, shape_idx) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton and event.pressed:
		tapped.emit()

# Recalculates all derived stats based on level and base stats
func set_stats():
	attack = calc_stat(luminae_data.base_attack)
	defense = calc_stat(luminae_data.base_defense)
	max_health = calc_hp()
	hp_bar.setup(max_health)
	health = max_health

# Calculates a stat like attack or defense using base stat, IV, EV
func calc_stat(base_stat: int, iv := 15, ev := 0) -> int:
	var stat = ((2 * base_stat + iv + int(ev / 4)) * level / 100.0) + 5
	return int(stat)

# Calculates the Pokémon's maximum HP using standard formula
func calc_hp():
	var IV = 15
	var EV = 0
	var HP = ((2 * luminae_data.base_health + IV + (EV / 4)) * level / 100) + level + 10
	return HP

func update_health(dmg):
	health = max(0, health - dmg)
	hp_bar.take_damage(dmg)
