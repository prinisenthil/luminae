extends Node

# Currency values
var gold = 50
var lumen_crystals = 5
var keys = 2

# Keyed by region name, then node name, then NodeState value
# e.g. { "region_1": { "BrightstoneVillage": 2, "GoldenMeadows": 1 } }
var node_states: Dictionary = {}

var current_region: String = "region_1"
var current_node: String = ""
var current_enemy: Luminae = null

var world = ""

var item_inventory: Dictionary = {}  # { ItemData: int }
var luminae_party: Array[Luminae] = []
var luminae_roster: Array[Luminae] = []

func _ready() -> void:
	_init_region_1()
	add_item(preload("res://resources/item resources/offerings/common_offering.tres"))
	add_item(preload("res://resources/item resources/offerings/common_offering.tres"))
	add_item(preload("res://resources/item resources/offerings/refined_offering.tres"))
	add_item(preload("res://resources/item resources/healing/healing_seed.tres"))
	add_item(preload("res://resources/item resources/healing/radiant_berry.tres"))
	add_item(preload("res://resources/item resources/experience/refined_crystal.tres"))
	add_luminae(Luminae.create_luminae(preload("res://resources/luminae resources/tidbit.tres"), 5, true))
	add_luminae(Luminae.create_luminae(preload("res://resources/luminae resources/fernling.tres"), 2, true))

func _init_region_1() -> void:
	# Only initialize if we haven't already (e.g. returning from battle)
	if node_states.has("region_1"):
		return

	node_states["region_1"] = {
		"BrightstoneVillage": MapNode.NodeState.AVAILABLE,
		"GoldenMeadows":      MapNode.NodeState.LOCKED,
		"DustyCrossroads":    MapNode.NodeState.LOCKED,
		"CrackedIdol":        MapNode.NodeState.LOCKED,
		"SunTempleRuins":     MapNode.NodeState.LOCKED,
		"MirageLake":         MapNode.NodeState.LOCKED,
		"ScorchedCanyon":     MapNode.NodeState.LOCKED,
		"EmberShelf":         MapNode.NodeState.LOCKED,
		"GildedDunes":        MapNode.NodeState.LOCKED,
		"SolaraThrone":       MapNode.NodeState.LOCKED,
	}

func add_gold(amount: int):
	gold += amount

func remove_gold(amount: int):
	gold -= amount

func add_lumen_crystals(amount: int):
	lumen_crystals += amount

func remove_lumen_crystals(amount: int):
	lumen_crystals -= amount

func add_keys(amount: int):
	keys += amount

func remove_keys(amount: int):
	keys -= amount

func add_item(item: ItemData, amount: int = 1) -> void:
	if item in item_inventory:
		item_inventory[item] += amount
	else:
		item_inventory[item] = amount

func remove_item(item: ItemData, amount: int = 1) -> void:
	if item not in item_inventory:
		return
	item_inventory[item] -= amount
	if item_inventory[item] <= 0:
		item_inventory.erase(item)

func capture_luminae(luminae: Luminae, nickname: String):
	#var new_luminae = Luminae.create_luminae(luminae.luminae_data, luminae.level, true, luminae.health, nickname)
	var new_luminae = Luminae.new()
	new_luminae.load_luminae(luminae)
	new_luminae.nickname = nickname
	new_luminae.player = true
	add_luminae(new_luminae)

# Add luminae to roster and/or party
func add_luminae(luminae: Luminae):
	if luminae in luminae_roster:
		return
	# add luminae to roster and party if free space
	luminae_roster.append(luminae)
	if luminae_party.size() < 4:
		luminae_party.append(luminae)

# remove (free) luminae from roster and party
func remove_luminae(luminae: Luminae):
	luminae_roster.erase(luminae)
	luminae_party.erase(luminae)

# Swap current battling luminae with selected party luminae
func swap_luminae(current: Luminae, selected: Luminae) -> void:
	var selected_index = luminae_party.find(selected)
	if selected_index == -1:
		return
	var temp = luminae_party[0]
	temp.load_luminae(current)
	luminae_party[0] = selected
	luminae_party[selected_index] = temp


func get_node_state(region: String, node_name: String) -> MapNode.NodeState:
	if not node_states.has(region):
		return MapNode.NodeState.LOCKED
	if not node_states[region].has(node_name):
		return MapNode.NodeState.LOCKED
	return node_states[region][node_name] as MapNode.NodeState


func set_node_state(region: String, node_name: String, state: MapNode.NodeState) -> void:
	if not node_states.has(region):
		node_states[region] = {}
	node_states[region][node_name] = state


func complete_node(region: String, node_name: String) -> void:
	set_node_state(region, node_name, MapNode.NodeState.COMPLETED)

func change_scene(scene):
	match scene:
		"battle":
			get_tree().change_scene_to_file("res://scenes/battle.tscn")
			world = "battle"
		"region_1":
			get_tree().change_scene_to_file("res://scenes/region maps/region_1.tscn")
			world = "map"
		"home":
			get_tree().change_scene_to_file("res://scenes/home.tscn")
			world = "home"
