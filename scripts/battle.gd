extends Node2D

@onready var player_luminae: Luminae = $PlayerLuminae
@onready var enemy_luminae: Luminae = $EnemyLuminae
@onready var orbs_text: Label = $PlayerControl/SpiritOrbs/Quantity
@onready var player_control = $PlayerControl
@onready var rewards_menu = $RewardsMenu
@onready var attack1: Attack = $PlayerControl/Attacks/attack1
@onready var attack1_btn: Button = $PlayerControl/Attacks/attack1/Button
@onready var attack2_btn: Button = $PlayerControl/Attacks/attack2/Button
@onready var attack2: Attack = $PlayerControl/Attacks/attack2
@onready var item_menu: ItemMenu = $PlayerControl/ItemMenu
@onready var items_btn: Button = $PlayerControl/Buttons/ItemsBtn
@onready var luminae_menu: LuminaeMenu = $PlayerControl/LuminaeMenu
@onready var luminaes_btn: Button = $PlayerControl/Buttons/LuminaePartyBtn
@onready var battle_popup = $BattlePopUpMenu

@onready var player_turn: bool = true

var battle_over: bool = false
var items_cancel_btn
var luminae_cancel_btn
var rewards: Dictionary

# executed upon battle start
func _ready() -> void:
	# Load first player luminae & decided enemy
	print(GameState.current_enemy.luminae_data.name)
	enemy_luminae.load_luminae(GameState.current_enemy, true)
	player_luminae.load_luminae(GameState.luminae_party[0], true)
	print(enemy_luminae.luminae_data.name)
	# Connect attack buttons & update orbs
	enemy_luminae.tapped.connect(_on_enemy_tapped)
	player_luminae.spirit_orbs = 3
	enemy_luminae.spirit_orbs = 3
	update_orbs()

	attack1_btn.pressed.connect(self._attack1_pressed)
	attack2_btn.pressed.connect(self._attack2_pressed)
	items_btn.pressed.connect(self.item_menu_pressed)
	luminaes_btn.pressed.connect(self.luminae_menu_pressed)
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

func luminae_menu_pressed():
	player_turn = false
	Fade("in", 0.3, luminae_menu)
	luminae_menu.populate_luminaes()
	luminae_menu.luminae_selected.connect(self._on_luminae_selected)
	luminae_cancel_btn = $PlayerControl/LuminaeMenu/CancelBtn
	luminae_cancel_btn.pressed.connect(self._luminaeCancelBtn_pressed)

func _on_luminae_selected(luminae: Luminae):
	if luminae.health <= 0:
		print("This luminae has fainted.")
		display_popup("This luminae has fainted.")
		return
	# Replace the active luminae
	GameState.swap_luminae(player_luminae, luminae)
	player_luminae.load_luminae(GameState.luminae_party[0], true)
	update_moves()

	close_luminae_menu()

func _luminaeCancelBtn_pressed():
	close_luminae_menu()

func close_luminae_menu():
	Fade("out", 0.3, luminae_menu)
	player_turn = true

func item_menu_pressed():
	player_turn = false
	hide_buttons()
	Fade("in", 0.3, item_menu)
	item_menu.populate_items()
	item_menu.item_selected.connect(self._on_item_selected)
	items_cancel_btn = $PlayerControl/ItemMenu/CancelBtn
	items_cancel_btn.pressed.connect(self._itemsCancelBtn_pressed)

func _on_item_selected(item: ItemData):
	if item.usable_mid_battle == false:
		print("Can't use that right now!")
		return
	match item.item_type:
		Global.ItemType.OFFERING:
			close_item_menu()
			print("CAPTURE IN PROGRESS")
			capture_process(item)
			GameState.remove_item(item)
		Global.ItemType.HEALING:
			player_luminae.use_item(item, true)
	item_menu.populate_items()

func _itemsCancelBtn_pressed():
	close_item_menu()

func close_item_menu():
	Fade("out", 0.2, item_menu)
	unhide_buttons()
	player_turn = true

func capture_process(item: ItemData):
	var chance = calc_capture_chance(item, player_luminae, enemy_luminae)
	var rand = randf()
	print("CHANCE: ", chance, " RAND: ", rand)
	if rand < chance:
		print("CAPTURE SUCCESS")
		end_battle(Global.BattleOutcome.CAPTURE)
		#end_battle(Global.BattleOutcome.CAPTURE)
		# success
	else:
		print("CAPTURE FAILED")
		await get_tree().create_timer(.5).timeout
		enemy_attack()
		return
		# failure - roll for flee distribution per GDD (50 stay / 30 flee / 20 attack+flee)
		#var flee_roll = randf()
		#if flee_roll < 0.5:
		#	pass  # stay, bond window reopens next turn
		#elif flee_roll < 0.8:
		#	return
		#else:
		#	enemy_luminae.attack(player_luminae)  # attack then flee
		#	return

func calc_capture_chance(offering: ItemData, player: Luminae, enemy: Luminae) -> float:
	if offering.item_tier == Global.ItemTier.LEGENDARY:
		return 1.0
	# base chance by offering tier
	var base_chance: float
	match offering.item_tier:
		Global.ItemTier.COMMON: base_chance = 0.5
		Global.ItemTier.REFINED: base_chance = 0.7
		Global.ItemTier.RADIANT: base_chance = 0.85
	# higher level player relative to enemy = easier to bond
	var level_diff = player.level - enemy.level
	var level_modifier = clamp(1.0 + (level_diff * 0.05), 0.6, 1.4)
	# lower hp = easier to bond, scales up to 1.5x at very low hp
	var hp_ratio = float(enemy.health) / float(enemy.max_health)
	var hp_modifier = clamp(1.0 + (1.0 - hp_ratio) * 0.5, 1.0, 1.5)
	# elemental artifact infusion bonus
	var artifact_bonus = 0.0
	if offering.infused_element != Global.ArtifactInfusion.NONE:
		if int(offering.infused_element) == int(enemy.element):
			artifact_bonus = 0.15
	return clamp(base_chance * level_modifier * hp_modifier + artifact_bonus, 0.0, 1.0)

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
	if move.energy_cost > player_luminae.spirit_orbs:
		print("Not enough spirit orbs!")
		return
	
	await player_attack(move)
	if battle_over:
		return
	await enemy_attack()

func player_attack(move: MoveData):
	player_turn = false
	execute_move(player_luminae, move, enemy_luminae)
	await player_luminae.sprite.animation_finished
	await get_tree().create_timer(0.5).timeout
	if enemy_luminae.health == 0:
		battle_over = true
		end_battle(Global.BattleOutcome.PLAYERWIN)
		return

func enemy_attack():
	await execute_move(enemy_luminae, enemy_luminae.luminae_data.basic_attack, player_luminae)
	await get_tree().create_timer(0.5).timeout
	print("Current health: ", player_luminae.health, " ", player_luminae.nickname)
	if player_luminae.health <= 0:
		await player_fainted()
	player_turn = true

func player_fainted():
	GameState.luminae_party[0].load_luminae(player_luminae)
	check_available_luminae()
	update_moves()
	if GameState.luminae_party[0].health <= 0:
		battle_over = true
		end_battle(Global.BattleOutcome.ENEMYWIN)

func check_available_luminae():
	for luminae in GameState.luminae_party:
		if luminae == GameState.luminae_party[0]:
			continue
		if luminae.health > 0: 
			await GameState.swap_luminae(player_luminae, luminae)
			player_luminae.load_luminae(GameState.luminae_party[0], true)
			break

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
	var level_scalar: float = max(float(attacker.level) / float(defender.level), 1.5)
	
	var base: float = float(move.power) * float(attacker.attack) / float(defender.defense)
	base *= level_scalar
	base *= 0.2  # global damage scalar — tune this until fights feel right
	if same_element:
		base *= 1.2
	return max(1, int(base * type_mult))  # always deal at least 1 damage

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

func end_battle(outcome: Global.BattleOutcome):
	if outcome == Global.BattleOutcome.PLAYERWIN:
		win_battle()
	elif outcome == Global.BattleOutcome.ENEMYWIN:
		lose_battle()
	elif outcome == Global.BattleOutcome.CAPTURE:
		battle_capture()

func win_battle() -> void:
	display_rewards()
	GameState.luminae_party[0].load_luminae(player_luminae)
#	distribute_battle_exp(enemy_luminae)
	GameState.complete_node(GameState.current_region, GameState.current_node)
	_unlock_next_node()
	#GameState.change_scene(GameState.current_region)

func display_rewards() -> void:
	hide_battle()
	rewards_menu.populate_rewards()
	Fade("in", 0.3, rewards_menu)
	var rewardsClaimBtn = $RewardsMenu/ClaimButton
	rewardsClaimBtn.pressed.connect(self._on_claim_pressed)

func _on_claim_pressed():
	claim_rewards()

func claim_rewards():
	for entry in GameState.node_rewards:
		match entry.reward_type:
			Global.RewardType.GOLD:
				GameState.add_gold(entry.quantity)
			Global.RewardType.LUMENCRYSTAL:
				GameState.add_lumen_crystals(entry.quantity)
			Global.RewardType.ITEM:
				GameState.add_item(entry.item, entry.quantity)
	GameState.change_scene(GameState.current_region)

func hide_battle() -> void:
	player_luminae.visible = false
	enemy_luminae.visible = false
	orbs_text.visible = false
	player_control.visible = false

func lose_battle() -> void:
	display_popup("Battle Lost.")
	$BattlePopUpMenu/OkayButton.pressed.connect(go_to_home)
	print("Battle Lost.")

func go_to_home():
	GameState.change_scene("home")

func battle_capture() -> void:
	print("Enemy Captured.")
	GameState.capture_luminae(enemy_luminae, "Peeb")
	GameState.luminae_party[0].load_luminae(player_luminae)
	print(GameState.luminae_party)
	hide_battle()
	display_popup("%s captured!" % enemy_luminae.nickname)
	$BattlePopUpMenu/OkayButton.pressed.connect(self._on_claim_pressed)

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

#func distribute_battle_exp(enemy: Luminae) -> void:
#	var full_exp = calc_battle_exp(enemy, GameState.luminae_party[0])
#	var bench_exp = int(full_exp * 0.5)
#	
#	for i in range(GameState.luminae_party.size()):
#		var luminae = GameState.luminae_party[i]
#		if not is_instance_valid(luminae):
#			continue
#		if i == 0:
#			luminae.gain_exp(full_exp)
#		else:
#			luminae.gain_exp(bench_exp)

#func calc_battle_exp(enemy: Luminae, player: Luminae) -> int:
	# base exp from enemy's data and level
#	var base = enemy.luminae_data.base_exp * enemy.level
#	
#	# bonus for outlevel - higher exp if enemy is higher level than player
#	var level_diff = enemy.level - player.level
#	var level_bonus = clamp(1.0 + (level_diff * 0.1), 0.5, 2.0)
#	
#	# bonus for evolved luminae
#	var evolution_bonus = 1.0
#	if enemy.luminae_data.evolution == null:
#		# no further evolution = final stage = higher exp
#		evolution_bonus = 1.5
#	
#	return int(base * level_bonus * evolution_bonus)

func display_popup(text: String):
	luminae_menu.disable_buttons()
	$BattlePopUpMenu/Label.text = text
	Fade("in", 0.2, battle_popup)
	#battle_popup.visible = true
	$BattlePopUpMenu/OkayButton.pressed.connect(self._on_popup_okay_pressed)

func _on_popup_okay_pressed():
	Fade("out", 0.2, battle_popup)
	#battle_popup.visible = false
	luminae_menu.enable_buttons()

func hide_buttons():
	Fade("out", 0.1, luminaes_btn)
	Fade("out", 0.1, items_btn)
	#luminaes_btn.visible = false
	#items_btn.visible = false

func unhide_buttons():
	Fade("in", 0.1, luminaes_btn)
	Fade("in", 0.1, items_btn)
	#luminaes_btn.visible = true
	#items_btn.visible = true
