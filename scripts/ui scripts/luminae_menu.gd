extends Control
class_name LuminaeMenu

signal luminae_selected(luminae: Luminae)
@onready var grid = $GridContainer

func populate_luminaes():
	var luminae_party = GameState.luminae_party
	for child in grid.get_children():
		grid.remove_child(child)
	for luminae in luminae_party:
		if luminae == GameState.luminae_party[0]:
			continue
		var btn = preload("res://scenes/ui scenes/luminae_menu_button.tscn").instantiate()
		btn.setup(luminae)
		btn.pressed.connect(func(): emit_signal("luminae_selected", luminae))
		grid.add_child(btn)

func enable_buttons():
	for btn in grid.get_children():
		btn.disabled = false
	$CancelBtn.disabled = false

func disable_buttons():
	for btn in grid.get_children():
		btn.disabled = true
	$CancelBtn.disabled = true
