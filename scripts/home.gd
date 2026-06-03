extends Node2D
class_name Home

@onready var menu: LuminaeHomeMenu = $LuminaeHomeMenu
@onready var battleBtn: Button = $Panel2/GridContainer/BattleButton
@onready var gold_text: Label = $GridContainer/Gold/Label
@onready var crystals_text: Label = $GridContainer/LumenCrystals/Label
@onready var keys_text: Label = $GridContainer/Keys/Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu.populate_luminaes()
	battleBtn.pressed.connect(self._on_region_map_pressed)
	gold_text.text = str(GameState.gold)
	crystals_text.text = str(GameState.lumen_crystals)
	keys_text.text = str(GameState.keys)

func _on_region_map_pressed():
	GameState.change_scene(GameState.current_region)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
