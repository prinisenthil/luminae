extends Resource
class_name LuminaeData

@export var name: String
@export var element: Global.LuminaeElement

# Base stats used for stat calculation in battle
@export var base_health: int = 11		# Base HP stat
@export var base_attack: int = 10		# Base physical attack
@export var base_defense: int = 10		# Base physical defense
@export var base_speed: int = 100			# Speed determines turn order
@export var base_exp: int = 64

@export var level: int = 5				# Default starting level

# Tracking player encounter state (can be used for pokedex function later)
@export var captured: bool = false		# Whether this Pokémon has been caught
@export var seen: bool = false			# Whether this Pokémon has been encountered

# Move & Evolution data
@export var moves: Array[MoveData] = []  # List of moves
@export var evolution: LuminaeData

# Sprites/Animations
@export var sprite: Texture2D
@export var idle: SpriteFrames
@export var attack: SpriteFrames
