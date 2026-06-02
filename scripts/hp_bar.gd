# HPBar.gd
extends TextureProgressBar

var max_hp: int

func setup(p_hp: int, p_max_hp: int) -> void:
	max_hp = p_max_hp
	min_value = 0
	max_value = max_hp
	value = p_hp

func take_damage(amount: int) -> void:
	var tween = create_tween()
	tween.tween_property(self, "value", value - amount, 0.3)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

func heal(amount: int) -> void:
	var tween = create_tween()
	tween.tween_property(self, "value", min(value + amount, max_hp), 0.3)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
