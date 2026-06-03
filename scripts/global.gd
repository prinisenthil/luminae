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
