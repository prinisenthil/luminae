extends Control
class_name RewardsMenu

@onready var grid = $ScrollContainer/GridContainer

func populate_rewards():
	for child in grid.get_children():
		grid.remove_child(child)
	for reward in GameState.node_rewards:
		var icon = preload("res://scenes/ui scenes/reward_icon.tscn").instantiate()
		icon.setup(reward)
		grid.add_child(icon)
