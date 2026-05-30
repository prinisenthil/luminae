extends Node

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
	add_item(preload("res://item resources/offerings/common_offering.tres"))
	add_item(preload("res://item resources/offerings/common_offering.tres"))
	add_item(preload("res://item resources/offerings/refined_offering.tres"))
	add_luminae(Luminae.create_luminae(preload("res://luminae resources/tidbit.tres"), 8, true))

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
	var new_luminae = Luminae.create_luminae(luminae.luminae_data, luminae.level, true, luminae.health, nickname)
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
