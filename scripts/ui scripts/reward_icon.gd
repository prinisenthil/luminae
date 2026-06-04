extends Control
class_name RewardIcon

@export var type: Global.RewardType
@export var item: ItemData
@export var quantity: int


func setup(rewardType: Global.RewardType, num: int, itemInput: ItemData = null):
	var background: Panel = $Background
	var stylebox = $Icon.get_theme_stylebox("panel") as StyleBoxTexture
	var icon: StyleBoxTexture = stylebox.duplicate() as StyleBoxTexture
	$Icon.add_theme_stylebox_override("panel", icon)
	var quantity_label: Label = $Quantity/Label
	type = rewardType
	item = itemInput
	quantity = num
	
	# Set ui
	quantity_label.text = str(quantity)
	
	match type:
		Global.RewardType.GOLD:
			icon.texture = Global.coin_texture
		Global.RewardType.LUMENCRYSTAL:
			icon.texture = Global.lumenCrystal_texture
		Global.RewardType.ITEM:
			if (item):
				icon.texture = item.icon
