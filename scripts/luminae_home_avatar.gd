extends Panel
class_name LuminaeHomeAvatar

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var name_panel: Panel = $NamePanel

var luminae: Luminae

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play()

func setup(luminae_input: Luminae):
	luminae = luminae_input
	sprite = $AnimatedSprite2D
	sprite.sprite_frames = luminae.idle_anim
	sprite.play()
	$NamePanel/Label.text = luminae.nickname
