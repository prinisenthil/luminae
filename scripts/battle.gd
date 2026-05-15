extends Node2D

@onready var player_luminae: Luminae = $player_luminae
@onready var enemy_luminae: Luminae = $enemy_luminae
@onready var orbs_text: Label = $"Spirit Orbs"
@onready var attack1: Attack = $Control/attack1
@onready var attack1_btn: Button = $Control/attack1/Button
@onready var attack2_btn: Button = $Control/attack2/Button
@onready var attack2: Attack = $Control/attack2
@onready var player_turn = true

# executed upon battle start
func _ready() -> void:
	enemy_luminae.tapped.connect(_on_enemy_tapped)
	player_luminae.spirit_orbs = 10
	enemy_luminae.spirit_orbs = 10
	update_orbs()

	attack1_btn.pressed.connect(self._attack1_pressed)
	attack2_btn.pressed.connect(self._attack2_pressed)
	update_moves()
	

# tap enemy sprite and perform basic attack
func _on_enemy_tapped() -> void:
	perform_attack(player_luminae.luminae_data.basic_attack)

# click special atk button 1 and use special attack 1
func _attack1_pressed():
	perform_attack(player_luminae.luminae_data.special_attack1)

# click special atk button 2 and use special attack 2
func _attack2_pressed():
	perform_attack(player_luminae.luminae_data.special_attack2)

# helper function to perform and animate specific attack move
func perform_attack(move: MoveData):
	# only attack during player's turn & if player has enough spirit orbs
	if not player_turn:
		return
	if (move.energy_cost > player_luminae.spirit_orbs):
		print("Not enough spirit orbs!")
		return

	player_turn = false
	execute_move(player_luminae, move, enemy_luminae)
	await player_luminae.sprite.animation_finished
	await get_tree().create_timer(0.5).timeout
	execute_move(enemy_luminae, enemy_luminae.luminae_data.basic_attack, player_luminae)
	player_turn = true

# helper function to apply damage and execute move then update player spirit orbs
func execute_move(attacker: Luminae, move: MoveData, defender: Luminae):
	attacker.spirit_orbs -= move.energy_cost
	update_orbs()
	attacker.play_attack()
	await attacker.sprite.animation_finished
	attacker.play_idle()
	var dmg = calc_dmg(attacker, defender, move)
	take_dmg(defender, dmg)
	attacker.spirit_orbs += calc_spirit_orbs(dmg, move.energy_cost)
	update_orbs()
	print("Level: ", attacker.level, " Move: ", move.display_name, " Power: ", move.power, " Dmg: ", dmg)

func calc_dmg(attacker: Luminae, defender: Luminae, move: MoveData) -> int:
	var type_mult: float = get_type_multiplier(move.element, defender.luminae_data.element)
	var same_element: bool = (move.element != Global.MoveElement.NORMAL 
		and int(move.element) == int(attacker.luminae_data.element))
	var level_scalar: float = float(attacker.level) / float(defender.level)
	
	var base: float = float(move.power) * float(attacker.attack) / float(defender.defense)
	base *= level_scalar
	if same_element:
		base *= 1.2
	return int(base * type_mult)

func get_type_multiplier(move_element: Global.MoveElement, defender_element: Global.LuminaeElement) -> float:
	# Normal moves have no type interaction
	if move_element == Global.MoveElement.NORMAL:
		return 1.0
	
	if Global.TYPE_ADVANTAGES[move_element] == defender_element:
		return 1.5
	elif Global.TYPE_DISADVANTAGES[move_element] == defender_element:
		return 0.75
	return 1.0

func take_dmg(defender, dmg):
	defender.update_health(dmg)

func calc_spirit_orbs(damage: int, move_cost: int) -> int:
	# Base: roughly 1 orb per 20 damage dealt
	var base: float = damage / 20.0
	# Random multiplier between 0.85 and 1.15 (tighter range, less swingy)
	var rng: float = randf_range(0.85, 1.15)
	# Cost bonus rewards committing to expensive moves
	var cost_bonus: float = move_cost * 0.3
	# Minimum 1 orb always
	return max(1, int((base + cost_bonus) * rng))

func update_orbs():
	orbs_text.text = str(player_luminae.spirit_orbs)

func update_moves():
	attack1.setup(player_luminae.luminae_data.special_attack1)
	attack2.setup(player_luminae.luminae_data.special_attack2)
