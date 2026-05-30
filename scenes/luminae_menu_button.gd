extends Button
class_name LuminaeMenuButton

@export var luminae: Luminae

func setup(luminae_input: Luminae):
	luminae = luminae_input
	$Sprite.texture = luminae.luminae_data.sprite
	$Label.text = luminae.nickname
