extends Control
class_name PopUpMenu


func displayError(text: String, secs: float = 0.1):
	$Label.text = text
	Fade("in", secs)
	$OkayButton.pressed.connect(self._on_okay_pressed)

func _on_okay_pressed():
	Fade("out", 0.1)

# helper function to fade menus in and out
func Fade(str: String, secs: float, obj=self):
	match str:
		"in":
			obj.modulate.a = 0.0
			var new_tween = create_tween()
			new_tween.tween_property(obj, "modulate:a", 1.0, secs)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_OUT)
			obj.visible = true
		"out":
			var new_tween = create_tween()
			new_tween.tween_property(obj, "modulate:a", 0.0, secs)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_IN)
			await new_tween.finished
			obj.visible = false
