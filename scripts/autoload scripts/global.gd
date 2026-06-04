extends Node

# Global Game State script autoloaded in project settings

# luminae spirit element enum
enum LuminaeElement {
	SUN,
	OCEAN,
	NATURE,
	SKY,
	NIGHT
}

# luminae move element enum
enum MoveElement {
	SUN,
	OCEAN,
	NATURE,
	SKY,
	NIGHT,
	NORMAL
}

enum LuminaeRarity {
	COMMON,
	REFINED,
	RADIANT,
	LEGENDARY,
	ETERNAL
}

enum ItemType {
	HEALING,
	OFFERING,
	EXPERIENCE,
	ECHO,
	ARTIFACT
}

enum ItemTier {
	COMMON,
	REFINED, 
	RADIANT,
	LEGENDARY
}

enum RewardType {
	GOLD,
	LUMENCRYSTAL,
	ITEM
}

enum ArtifactType {
	ELEMENTAL,
	ETERNAL
}

enum ArtifactInfusion {
	NONE,
	SUN,
	OCEAN,
	NATURE,
	SKY,
	NIGHT
}

enum BattleOutcome {
	PLAYERWIN,
	ENEMYWIN,
	CAPTURE
}

# battle type advantage chart
# Sun > Nature > Ocean > Sky > Night > Sun
const TYPE_ADVANTAGES: Dictionary = {
	MoveElement.SUN: LuminaeElement.NATURE,
	MoveElement.NATURE: LuminaeElement.OCEAN,
	MoveElement.OCEAN: LuminaeElement.SKY,
	MoveElement.SKY: LuminaeElement.NIGHT,
	MoveElement.NIGHT: LuminaeElement.SUN
}

# battle type disadvantage chart
const TYPE_DISADVANTAGES: Dictionary = {
	MoveElement.SUN: LuminaeElement.NIGHT,
	MoveElement.NATURE: LuminaeElement.SUN,
	MoveElement.OCEAN: LuminaeElement.NATURE,
	MoveElement.SKY: LuminaeElement.OCEAN,
	MoveElement.NIGHT: LuminaeElement.SKY
}

# Define which node unlocks after which — this is your progression graph
var unlock_map: Dictionary = {
	"BrightstoneVillage": ["GoldenMeadows"],
	"GoldenMeadows":      ["DustyCrossroads"],
	"DustyCrossroads":    ["SunTempleRuins", "CrackedIdol"],  # main + side branch
	"SunTempleRuins":     ["MirageLake"],
	"MirageLake":         ["ScorchedCanyon", "GildedDunes"],
	"ScorchedCanyon":     ["SolaraThrone"],
}

var coin_texture: Texture2D = preload("res://art/placeholders/Vector_UI_Pack_dobo_ui/Icons/64px/coin_icon_64px.png")
var lumenCrystal_texture: Texture2D = preload("res://art/placeholders/Vector_UI_Pack_dobo_ui/Icons/64px/gem_icon_64px.png")

# attack button textures
var nature_attack_texture: StyleBoxTexture = preload("res://art/placeholders/ui/attack buttons/button styles/nature_button.tres")
var nature_attack_pressed_texture: StyleBoxTexture = preload("res://art/placeholders/ui/attack buttons/hover styles/nature_hover.tres")
var ocean_attack_texture: StyleBoxTexture = preload("res://art/placeholders/ui/attack buttons/button styles/ocean_button.tres")
var ocean_attack_pressed_texture: StyleBoxTexture = preload("res://art/placeholders/ui/attack buttons/hover styles/ocean_hover.tres")
var sun_attack_texture: StyleBoxTexture = preload("res://art/placeholders/ui/attack buttons/button styles/sun_button.tres")
var sun_attack_pressed_texture: StyleBoxTexture = preload("res://art/placeholders/ui/attack buttons/hover styles/sun_hover.tres")

# luminae menu style textures
var nature_luminae_menu = preload("res://art/placeholders/ui/luminae button styles/nature_style.tres")
var nature_luminae_menu_pressed = preload("res://art/placeholders/ui/luminae button styles/nature_style_pressed.tres")
var ocean_luminae_menu = preload("res://art/placeholders/ui/luminae button styles/ocean_style.tres")
var ocean_luminae_menu_pressed = preload("res://art/placeholders/ui/luminae button styles/ocean_style_pressed.tres")
var sun_luminae_menu = preload("res://art/placeholders/ui/luminae button styles/sun_style.tres")
var sun_luminae_menu_pressed = preload("res://art/placeholders/ui/luminae button styles/sun_style_pressed.tres")

# level up button styles
var level_up_texture = preload("res://art/placeholders/ui/other styleboxes/levelup.tres")
var level_up_pressed = preload("res://art/placeholders/ui/other styleboxes/levelup_pressed.tres")
var level_up_available_texture = preload("res://art/placeholders/ui/other styleboxes/levelup_available.tres")
var level_up_available_pressed = preload("res://art/placeholders/ui/other styleboxes/levelup_available_pressed.tres")
