extends Button
class_name ItemMenuButton

@export var item: ItemData

func setup(item_data: ItemData, quantity: int):
	item = item_data
	$Sprite.texture = item.icon
	$Name.text = item.name
	$Quantity.text = str(quantity)
