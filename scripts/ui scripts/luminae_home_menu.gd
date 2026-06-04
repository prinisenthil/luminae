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
		avatar.tapped.connect(func(): _on_avatar_tapped(avatar))
		avatar.closed.connect(self._on_info_closed)
		grid.add_child(avatar)

func _on_avatar_tapped(selected_avatar: LuminaeHomeAvatar) -> void:
	for child in grid.get_children():
		child.visible = (child == selected_avatar)

func _on_info_closed():
	for child in grid.get_children():
		child.visible = true
