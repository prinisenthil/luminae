extends Control
class_name LuminaeHomeMenu

@onready var grid = $ScrollContainer/GridContainer

func populate_luminaes():
	var luminae_roster = GameState.luminae_roster
	for child in grid.get_children():
		grid.remove_child(child)
	for luminae in luminae_roster:
		var avatar = preload("res://scenes/ui scenes/luminae_home_avatar.tscn").instantiate()
		avatar.setup(luminae)
		grid.add_child(avatar)
