extends Node2D

@onready var player_luminae: Luminae = $player_luminae
@onready var enemy_luminae: Luminae = $enemy_luminae
@onready var orbs_text: Label = $"Spirit Orbs"
@onready var attack1: Attack = $Control/attack1
@onready var attack1_btn: Button = $Control/attack1/Button
@onready var attack2_btn: Button = $Control/attack2/Button
@onready var attack2: Attack = $Control/attack2
@onready var item_menu: ItemMenu = $ItemMenu
@onready var items_btn: Button = $ItemsBtn
@onready var player_turn = true

var items_cancel_btn

# executed upon battle start
func _ready() -> void:
	print(GameState.current_enemy.luminae_data.name)
	enemy_luminae.load_luminae(GameState.current_enemy)
	print(enemy_luminae.luminae_data.name)
	enemy_luminae.tapped.connect(_on_enemy_tapped)
	player_luminae.spirit_orbs = 3
	enemy_luminae.spirit_orbs = 3
	update_orbs()

	attack1_btn.pressed.connect(self._attack1_pressed)
	attack2_btn.pressed.connect(self._attack2_pressed)
	items_btn.pressed.connect(self.item_menu_pressed)
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

func item_menu_pressed():
	player_turn = false
	Fade("in", 0.3, item_menu)
	item_menu.populate_items()
	item_menu.item_selected.connect(self._on_item_selected)
	items_cancel_btn = $ItemMenu/CancelBtn
	items_cancel_btn.pressed.connect(self._itemsCancelBtn_pressed)

func _on_item_selected(item: ItemData):
	GameState.remove_item(item)
	item_menu.populate_items()

func _itemsCancelBtn_pressed():
	Fade("out", 0.3, item_menu)
	player_turn = true

# helper function to fade menus in and out
func Fade(str: String, secs: float, obj, obj2 = null):
	match str:
		"in":
			obj.modulate.a = 0.0
			var new_tween = create_tween()
			new_tween.tween_property(obj, "modulate:a", 1.0, secs)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_OUT)
			obj.visible = true
		"out":
			if obj2:
				var new_tween = create_tween()
				new_tween.parallel().tween_property(obj, "modulate:a", 0.0, secs)\
					.set_trans(Tween.TRANS_SINE)\
					.set_ease(Tween.EASE_IN)
				new_tween.parallel().tween_property(obj2, "modulate:a", 0.0, secs)\
					.set_trans(Tween.TRANS_SINE)\
					.set_ease(Tween.EASE_IN)
				await new_tween.finished
				obj.visible = false
				obj2.visible = false
			else:
				var new_tween = create_tween()
				new_tween.tween_property(obj, "modulate:a", 0.0, secs)\
					.set_trans(Tween.TRANS_SINE)\
					.set_ease(Tween.EASE_IN)
				await new_tween.finished
				obj.visible = false

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
	await get_tree().create_timer(.5).timeout
	if enemy_luminae.health == 0:
		win_battle()
		return

	execute_move(enemy_luminae, enemy_luminae.luminae_data.basic_attack, player_luminae)
	await get_tree().create_timer(.5).timeout
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

# battle.gd
func win_battle() -> void:
	GameState.complete_node(GameState.current_region, GameState.current_node)
	_unlock_next_node()
	GameState.change_scene(GameState.current_region)


func _unlock_next_node() -> void:
	var completed = GameState.current_node
	if Global.unlock_map.has(completed):
		for next_node in Global.unlock_map[completed]:
			GameState.set_node_state(
				GameState.current_region,
				next_node,
				MapNode.NodeState.AVAILABLE
			)

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
	var orbs = player_luminae.spirit_orbs
	orbs_text.text = str(orbs)
	if orbs < player_luminae.luminae_data.special_attack1.energy_cost:
		attack1.set_availability(false)
	else:
		attack1.set_availability(true)
	if orbs < player_luminae.luminae_data.special_attack2.energy_cost:
		attack2.set_availability(false)
	else:
		attack2.set_availability(true)
	

func update_moves():
	attack1.setup(player_luminae.luminae_data.special_attack1)
	attack2.setup(player_luminae.luminae_data.special_attack2)
