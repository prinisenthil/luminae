extends Control
class_name LuminaeAvatarInfo

var luminae: Luminae
var evolutionEntry: EvolutionEntry
var level_up_available: bool = true
var hp_label: Label
var hp_bar: TextureProgressBar
var first_stats: Label
var sec_stats: Label

var heal_menu_open: bool = false

signal leveledUp

func setup(luminae_input: Luminae):
	luminae = luminae_input
	update_header()
	evolutionEntry = luminae.luminae_data.evolution
	if evolutionEntry == null:
		$GridContainer.remove_child($GridContainer/EvolveBtn)
	hp_label = $Stats/HPPanel/HPLabel
	hp_bar = $Stats/HPPanel/HPBar
	first_stats = $Stats/LuminaeStats/Grid/StatsLabel
	sec_stats = $Stats/LuminaeStats/Grid/StatsLabel3
	set_pages()
	hide_pages()
	$Stats.visible = true
	
	print($GridContainer.get_children())
	$GridContainer/StatsBtn.pressed.connect(self._stats_pressed)
	$GridContainer/EvolveBtn.pressed.connect(self._evolve_pressed)
	$Growth/LevelUp.pressed.connect(self._level_up_pressed)
	$Stats/QuickHealButton.pressed.connect(_toggle_heal_menu)

func update_header():
	$Header/Name.text = luminae.nickname
	$Header/Level.text = "Lvl. %d" % luminae.level

func _toggle_heal_menu():
	heal_menu_open = !heal_menu_open
	if heal_menu_open:
		$Stats/LuminaeStats.visible = false
		$Stats/QuickHealButton/HealItems.visible = true
		set_heal_items()
	else:
		$Stats/QuickHealButton/HealItems.visible = false
		$Stats/LuminaeStats.visible = true

func _evolve_pressed():
	openEvolve()

func _stats_pressed():
	openStats()

func _level_up_pressed():
	levelUp()

func levelUp():
	if level_up_available:
		level_up_available = false
		luminae.levelUp()
		leveledUp.emit()
		set_pages()
		update_header()
		print($Stats/HPPanel/HPBar.value)
	else:
		$PopUpMenu.displayError("Not enough gold!")

func openEvolve():
	if ($Growth.visible == true):
		return
	hide_pages()
	$Growth.visible = true

func openStats():
	if ($Stats.visible == true):
		return
	hide_pages()
	$Stats.visible = true

func set_pages():
	set_stats_page()
	set_growth_page()
	set_levelup()

func set_levelup():
	$Growth/LevelUp/Label.text = str(luminae.getLevelUpCost())
	if GameState.gold >= luminae.getLevelUpCost():
		level_up_available = true
		$Growth/LevelUp.disabled = false
	else:
		$Growth/LevelUp.disabled = true


func hide_pages():
	$Stats.visible = false
	$Growth.visible = false

func set_growth_page():
	if evolutionEntry:
		$Growth/Evolve/Label.text = "Evolve    Lv. %d" % [evolutionEntry.level]
		$Growth/EvolutionSprite.texture = evolutionEntry.evolution.sprite
	$Growth/GrowthPreview/Levels.text =  "Level  %d -> %d" % [luminae.level, (luminae.level + 1)]
	var growth_str = "HP  +%d  |  ATK  +%d  |  DEF  +%d  \nSPD  +%d  |  CRT  +%d%%" % [luminae.get_health_diff(), luminae.get_stat_diff(luminae.luminae_data.base_attack), luminae.get_stat_diff(luminae.luminae_data.base_defense), luminae.get_stat_diff(luminae.luminae_data.base_speed), luminae.get_stat_diff(luminae.luminae_data.base_crit)] 
	$Growth/GrowthPreview/Stats.text = growth_str

func set_stats_page():
	var health_str = "HP:  %d  /  %d" % [luminae.health, luminae.max_health]
	var stats_str = "ATK:  %d \nSPD:  %d" % [luminae.attack, luminae.speed]
	var stats_str3 = "DEF:  %d \nCRT:  %d%%" % [luminae.defense, luminae.crit_chance]
	hp_label.text = health_str
	hp_bar.max_value = luminae.max_health
	hp_bar.value = luminae.health
	first_stats.text = stats_str
	sec_stats.text = stats_str3

func set_heal_items():
	var grid = $Stats/QuickHealButton/HealItems
	for child in grid.get_children():
		grid.remove_child(child)
	var item_inv = GameState.item_inventory
	for item: ItemData in item_inv:
		if item.item_type == Global.ItemType.HEALING:
			var quantity = item_inv[item]
			var btn = preload("res://scenes/ui scenes/buttons/quick_heal_item_button.tscn").instantiate()
			btn.setup(item.name, quantity, item.hp_restore)
			btn.pressed.connect(func(): use_heal_item(item))
			grid.add_child(btn)
	$Stats/QuickHealButton/HealItems.visible = true

func use_heal_item(item: ItemData):
	luminae.use_item(item)
	set_heal_items()
	set_stats_page()
