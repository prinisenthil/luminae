extends Panel
class_name LuminaeHomeAvatar

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var name_panel: Panel = $Tag

var luminae: Luminae

signal tapped
signal closed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play()

func setup(luminae_input: Luminae):
	luminae = luminae_input
	sprite = $AnimatedSprite2D
	sprite.sprite_frames = luminae.idle_anim
	sprite.play()
	$InfoPanel.setup(luminae)
	$InfoPanel/CancelBtn.pressed.connect(self._on_cancel_pressed)
	$InfoPanel.leveledUp.connect(self.updateTag)
	$Button.pressed.connect(self._on_pressed)
	updateTag()

func updateTag():
	$Tag/NameText.text = luminae.nickname
	$Tag/LevelText.text = "Lv. %d" % luminae.level
	$Tag/HPBar.max_value = luminae.max_health
	$Tag/HPBar.value = luminae.health

func _on_pressed():
	tapped.emit()
	name_panel.visible = false
	$InfoPanel.visible = true

func _on_cancel_pressed():
	closed.emit()
	$InfoPanel.visible = false
	updateTag()
	name_panel.visible = true
