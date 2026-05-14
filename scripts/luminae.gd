extends Node2D

@export var luminae_data: LuminaeData
@export var player: bool

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hp_bar: ProgressBar = $HPBar
@onready var attack_origin: Marker2D = $AttackOrigin
@onready var impact_point: Marker2D = $ImpactPoint
@onready var idle_anim: SpriteFrames = luminae_data.idle
@onready var attack_anim: SpriteFrames = luminae_data.attack

func _ready():
	if not player:
		sprite.flip_h = false
	sprite.sprite_frames = idle_anim
	sprite.play()
