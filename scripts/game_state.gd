extends Node

# Keyed by region name, then node name, then NodeState value
# e.g. { "region_1": { "BrightstoneVillage": 2, "GoldenMeadows": 1 } }
var node_states: Dictionary = {}

var current_region: String = "region_1"
var current_node: String = ""

var world = ""

func _ready() -> void:
	_init_region_1()

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
