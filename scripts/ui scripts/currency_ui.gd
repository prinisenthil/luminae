extends Control

@onready var gold_text: Label = $GridContainer/Gold/Label
@onready var crystals_text: Label = $GridContainer/LumenCrystals/Label
@onready var keys_text: Label = $GridContainer/Keys/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateCurrency()
	GameState.currency_changed.connect(self.updateCurrency)

func updateCurrency():
	gold_text.text = str(GameState.gold)
	crystals_text.text = str(GameState.lumen_crystals)
	keys_text.text = str(GameState.keys)
