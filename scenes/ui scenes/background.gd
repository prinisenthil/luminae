extends Panel


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	modulate = Color(1.2, 1.2, 1.2, 1.0)

func _on_mouse_exited() -> void:
	modulate = Color.WHITE
