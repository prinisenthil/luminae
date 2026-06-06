extends Node2D
class_name Home

@onready var menu: LuminaeHomeMenu = $LuminaeHomeMenu
@onready var battleBtn: Button = $MenuButtons/Background/GridContainer/BattleButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu.populate_luminaes()
	battleBtn.pressed.connect(self._on_region_map_pressed)


func _on_region_map_pressed():
	GameState.change_scene(GameState.current_region)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
