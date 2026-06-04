extends Control
class_name RewardsMenu

@onready var grid = $ScrollContainer/GridContainer

var rewards: Dictionary

func populate_rewards(rewards: Dictionary):
	for child in grid.get_children():
		grid.remove_child(child)
	for reward in rewards:
		var icon = preload("res://scenes/ui scenes/reward_icon.tscn").instantiate()
		icon.setup(reward, rewards[reward])
		grid.add_child(icon)
