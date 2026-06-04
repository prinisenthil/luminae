extends Control
class_name LuminaeAvatarInfo

var luminae: Luminae
var evolutionEntry: EvolutionEntry
var level_up_available: bool = true

signal leveledUp

func setup(luminae_input: Luminae):
	luminae = luminae_input
	$Header/Name.text = luminae.nickname
	evolutionEntry = luminae.luminae_data.evolution
	if evolutionEntry == null:
		$GridContainer.remove_child($GridContainer/EvolveBtn)
	set_pages()
	hide_pages()
	$Stats.visible = true
	
	$GridContainer/StatsBtn.pressed.connect(self._stats_pressed)
	$GridContainer/EvolveBtn.pressed.connect(self._evolve_pressed)
	$LevelUp.pressed.connect(self._level_up_pressed)

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
		set_pages()
		leveledUp.emit()
	else:
		$PopUpMenu.displayError("Not enough gold!")

func openEvolve():
	if ($Evolve.visible == true):
		return
	hide_pages()
	$Evolve.visible = true

func openStats():
	if ($Stats.visible == true):
		return
	hide_pages()
	$Stats.visible = true

func set_pages():
	set_stats_page()
	if evolutionEntry:
		set_evolution_page()
	set_levelup()

func set_levelup():
	$LevelUp/Label.text = str(luminae.getLevelUpCost())
	if GameState.gold >= luminae.getLevelUpCost():
		level_up_available = true
		$LevelUp.add_theme_stylebox_override("normal", Global.level_up_available_texture)
		$LevelUp.add_theme_stylebox_override("pressed", Global.level_up_available_pressed)
	else:
		$LevelUp.add_theme_stylebox_override("normal", Global.level_up_texture)
		$LevelUp.add_theme_stylebox_override("pressed", Global.level_up_pressed)


func hide_pages():
	$Stats.visible = false
	$Evolve.visible = false

func set_evolution_page():
	$Evolve/LevelNum.text = "Level %d" % [evolutionEntry.level]
	$Evolve/EvolutionSprite.texture = evolutionEntry.evolution.sprite

func set_stats_page():
	var stats_str = "Attack: %d \nSpeed: %d \nMax HP: %d" % [luminae.attack, luminae.speed, luminae.max_health]
	$Stats/FirstStats.text = stats_str
	var stats_str2 = "Defense: %d \nCrit Chance: %d%%" % [luminae.defense, luminae.crit_chance]
	$Stats/SecondStats.text = stats_str2
