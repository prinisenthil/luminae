extends Node2D
class_name Luminae

@export var luminae_data: LuminaeData
@export var player: bool
@export var nickname: String
@export var level: int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var tap_area: Area2D = $Area2D
@onready var hp_bar: TextureProgressBar = $Control/HPBar
@onready var attack_origin: Marker2D = $AttackOrigin
@onready var impact_point: Marker2D = $ImpactPoint
@onready var name_label: Label = $Control/NamePanel/Name
@onready var level_label: Label = $Control/NamePanel/Level
@onready var idle_anim: SpriteFrames = luminae_data.idle
@onready var attack_anim: SpriteFrames = luminae_data.attack

# Calculated stats based on level and base values
var attack: int
var defense: int
var speed: int
var crit_chance: int
var max_health: int

var attack_boost: int
var defense_boost: int
var crit_chance_boost: int
var max_health_boost: int
var health: int
var level_up_cost: int
#var max_exp: int
#var exp: int
var spirit_orbs

signal tapped

func _ready():
	setup()

# set up luminae for battle (sprites, anims, hp bar)
func setup():
	set_variables()
	name_label.text = nickname
	level_label.text = "Lvl. %d" % level
	if not player:
		sprite.flip_h = false
	else:
		tap_area.monitoring = false
	sprite.sprite_frames = idle_anim
	sprite.play()
	#set_stats()

func set_variables():
	idle_anim = luminae_data.idle
	attack_anim = luminae_data.attack
	if (nickname == ""):
		nickname = luminae_data.name

static func create_luminae(luminae_data: LuminaeData, level: int, player: bool, health = null, nick = null) -> Luminae:
	var new_luminae := Luminae.new()
	new_luminae.luminae_data = luminae_data
	new_luminae.level = level
	new_luminae.player = player
	new_luminae.set_variables()
	new_luminae.set_stats()
	if health != null:
		new_luminae.health = health
	if nick != null:
		new_luminae.nickname = nick
	return new_luminae

func load_luminae(luminae: Luminae, battling=false) -> void:
	nickname = luminae.nickname
	luminae_data = luminae.luminae_data
	level = luminae.level
	player = luminae.player
	set_variables()
	set_stats(luminae)
	if battling:
		setup()

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
func set_stats(luminae: Luminae = null):
	if luminae:
		level = luminae.level
		attack_boost = luminae.attack_boost
		defense_boost = luminae.defense_boost
		crit_chance_boost = luminae.crit_chance_boost
		max_health_boost = luminae.max_health_boost
		health = luminae.health
		level_up_cost = getLevelUpCost()
		recalc_stats()
#		max_exp = luminae.max_exp
#		exp = luminae.exp
	else:
		recalc_stats()
		health = max_health
	if (hp_bar):
		hp_bar.setup(health, max_health)

func recalc_stats():
	attack = calc_stat(luminae_data.base_attack, attack_boost)
	defense = calc_stat(luminae_data.base_defense, defense_boost)
	max_health = calc_hp()
	level_up_cost = getLevelUpCost()
#	max_exp = exp_to_next_level()

func get_stat_diff(base_stat: int):
	var initial_stat = base_stat + int((base_stat * 0.15) * (level - 1))
	var next_stat = base_stat + int((base_stat * 0.15) * (level))
	return next_stat - initial_stat

func get_health_diff():
	var initial_max = luminae_data.base_health + int((luminae_data.base_health * 0.2) * (level - 1))
	var next_max = luminae_data.base_health + int((luminae_data.base_health * 0.2) * (level))
	return next_max - initial_max

# level 1 returns base stat exactly, grows linearly each level
func calc_stat(base_stat: int, boost: int) -> int:
	return base_stat + int((base_stat * 0.15) * (level - 1)) + boost

# HP grows slightly faster than other stats
func calc_hp() -> int:
	return luminae_data.base_health + int((luminae_data.base_health * 0.2) * (level - 1)) + max_health_boost

#func exp_to_next_level() -> int:
#	return int(luminae_data.base_exp * (level * level) * 0.5)

func update_health(dmg):
	health = max(0, health - dmg)
	hp_bar.take_damage(dmg)

#func gain_exp(amount: int) -> void:
#	exp += amount
#	while exp >= exp_to_next_level():
#		exp -= exp_to_next_level()
#		levelUp()

func levelUp() -> void:
	var level_up_cost = getLevelUpCost()
	if GameState.gold < level_up_cost:
		return
	level += 1
	var max_health_initial = max_health
	recalc_stats()
	if health > 0:
		health += max_health - max_health_initial
	GameState.remove_gold(level_up_cost)
	# trigger level up animation/signal here

func use_item(item: ItemData, battling = false):
	if item.item_type == Global.ItemType.HEALING:
		var restore_amount = item.hp_restore
		restore_health(restore_amount, battling)
		GameState.remove_item(item)

func restore_health(hp_restore: int, battling=false):
	health = min(health + hp_restore, max_health)
	if battling:
		hp_bar.heal(hp_restore)

func getLevelUpCost():
	var rarity_mult = 1.0
	var base_cost = 40
	match luminae_data.rarity:
		Global.LuminaeRarity.REFINED:
			rarity_mult = 1.2
		Global.LuminaeRarity.RADIANT:
			rarity_mult = 1.4
		Global.LuminaeRarity.ETERNAL:
			rarity_mult = 1.6
	return int(base_cost * pow(level, 1.5) * rarity_mult)
