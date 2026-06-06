extends Button
class_name QuickHealItemButton

func setup(name: String, quantity: int, heal_amt: int):
	var str = "%s    x%d  (+%d)" % [name, quantity, heal_amt]
	$Label.text = str
