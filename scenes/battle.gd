extends Node2D

@onready var player_luminae: Luminae = $player_luminae
@onready var enemy_luminae: Luminae = $enemy_luminae
@onready var orbs_text: Label = $"Spirit Orbs"
@onready var attack1_button: Button = $Control/attack1/Button
@onready var attack2_button: Button = $Control/attack2/Button
@onready var player_turn = true

func _ready() -> void:
	enemy_luminae.tapped.connect(_on_enemy_tapped)
	player_luminae.spirit_orbs = 10
	enemy_luminae.spirit_orbs = 10
	update_orbs()

func _on_enemy_tapped() -> void:
	# Only allow tap during player's turn
	if not player_turn:
		return
	player_turn = false
	execute_move(player_luminae, player_luminae.luminae_data.basic_attack, enemy_luminae)
	await player_luminae.sprite.animation_finished
	update_orbs()
	await get_tree().create_timer(0.5).timeout
	execute_move(enemy_luminae, enemy_luminae.luminae_data.basic_attack, player_luminae)
	player_turn = true

func execute_move(attacker: Luminae, move: MoveData, defender: Luminae):
	attacker.spirit_orbs -= move.energy_cost
	attacker.play_attack()
	await attacker.sprite.animation_finished
	attacker.play_idle()
	var dmg = calc_dmg(attacker, defender, move.power)
	take_dmg(defender, dmg)
	attacker.spirit_orbs += calc_spirit_orbs(dmg, move.energy_cost)

func take_dmg(defender, dmg):
	defender.update_health(dmg)
	print(defender.health)

func calc_spirit_orbs(damage: int, move_cost: int) -> int:
	# Base: roughly 1 orb per 8 damage dealt
	var base = damage / 8.0
	
	# Random multiplier between 0.75 and 1.25
	var rng = randf_range(0.75, 1.25)
	
	# Bonus for higher cost moves — rewards commitment
	var cost_bonus = 0  # move_cost * 0.5
	
	# Put it together, minimum 1 orb always
	return max(1, int((base + cost_bonus) * rng))

# Simple Pokémon damage formula
func calc_dmg(attacker, defender, power):
	var dmg = (2*attacker.level/5) + 2
	dmg *= power
	dmg *= (attacker.attack/defender.defense)
	dmg /= 50
	dmg += 2
	return round(dmg)

func calc_dmg_complex(attacker, defender, power, move_type: Global.MoveElement, is_critical := false) -> int:
	var level = attacker.level
	var attack = attacker.attack
	var defense = defender.defense
	# Base damage
	var dmg = (((2 * level / 5 + 2) * power * (attack / defense)) / 50) + 2
	# Modifiers
	var modifier = 1.0
	# STAB (Same Type Attack Bonus)
	if move_type == attacker.element:
		modifier *= 1.5
	# Random factor (between 0.85 and 1.0)
	modifier *= randf_range(0.85, 1.0)
	# Critical hit
	if is_critical:
		modifier *= 1.5
	# Type effectiveness (optional: check type chart here)
	# Example: if defender.element == "Water" and move_type == "Grass":
	#     modifier *= 2.0
	return round(dmg * modifier)

func update_orbs():
	orbs_text.text = str(player_luminae.spirit_orbs)
