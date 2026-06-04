extends Button
class_name ItemMenuButton

@export var item: ItemData

func _ready() -> void:
	mouse_entered.connect(func(): modulate = Color(1.2, 1.2, 1.2, 1.0))
	mouse_exited.connect(func(): modulate = Color.WHITE)

func setup(item_data: ItemData, quantity: int):
	item = item_data
	$Sprite.texture = item.icon
	$Name.text = item.name
	$Quantity/Label.text = str(quantity)
