extends Button
class_name LuminaeMenuButton

@export var luminae: Luminae

func setup(luminae_input: Luminae):
	luminae = luminae_input
	$Sprite.texture = luminae.luminae_data.sprite
	$Label.text = luminae.nickname
	$HPBar.max_value = luminae.max_health
	$HPBar.value = luminae.health
	
	match luminae.luminae_data.element:
		Global.LuminaeElement.NATURE:
			add_theme_stylebox_override("normal", Global.nature_luminae_menu)
			add_theme_stylebox_override("hover", Global.nature_luminae_menu)
			add_theme_stylebox_override("pressed", Global.nature_luminae_menu_pressed)
		Global.LuminaeElement.OCEAN:
			add_theme_stylebox_override("normal", Global.ocean_luminae_menu)
			add_theme_stylebox_override("hover", Global.ocean_luminae_menu)
			add_theme_stylebox_override("pressed", Global.ocean_luminae_menu_pressed)
		Global.LuminaeElement.SUN:
			add_theme_stylebox_override("normal", Global.sun_luminae_menu)
			add_theme_stylebox_override("hover", Global.sun_luminae_menu)
			add_theme_stylebox_override("pressed", Global.sun_luminae_menu_pressed)
