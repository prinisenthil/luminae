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
