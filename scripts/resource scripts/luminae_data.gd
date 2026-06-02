extends Resource
class_name LuminaeData

@export var name: String
@export var element: Global.LuminaeElement

# Base stats used for stat calculation in battle
@export var base_health: int = 60		# Base HP Stat
@export var base_attack: int = 6		# Base Attack Stat
@export var base_defense: int = 6		# Base Defense Stat
@export var base_speed: int = 10		# Base Speed Stat
@export var base_exp: int = 20

@export var level: int = 1				# Default starting level

# Tracking player encounter state (can be used for pokedex function later)
@export var captured: bool = false		# Whether this Pokémon has been caught
@export var seen: bool = false			# Whether this Pokémon has been encountered

# Move & Evolution data
@export var basic_attack: MoveData
@export var special_attack1: MoveData
@export var special_attack2: MoveData
@export var evolution: LuminaeData

# Sprites/Animations
@export var sprite: Texture2D
@export var idle: SpriteFrames
@export var attack: SpriteFrames
