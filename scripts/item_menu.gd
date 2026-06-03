extends Control
class_name ItemMenu

signal item_selected(item: ItemData)
@onready var grid = $ScrollContainer/GridContainer

func populate_items():
	var item_inv = GameState.item_inventory
	for child in grid.get_children():
		grid.remove_child(child)
	for item in item_inv:
		var quantity = item_inv[item]
		var btn = preload("res://scenes/ui scenes/item_menu_button.tscn").instantiate()
		btn.setup(item, quantity)
		btn.pressed.connect(func(): emit_signal("item_selected", item))
		grid.add_child(btn)
