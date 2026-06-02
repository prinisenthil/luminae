@tool
extends Resource
class_name ItemData

@export var name: String
@export var description: String
@export var icon: Texture2D
@export var item_type: Global.ItemType :
	set(value):
		item_type = value
		notify_property_list_changed()
		emit_changed()
@export var item_tier: Global.ItemTier # COMMON, REFINED, RADIANT, LEGENDARY
@export var craftable: bool = false
@export var crafting_recipe: Array[CraftingEntry]
@export var usable_mid_battle: bool = false
@export var stackable: bool = false
@export var max_stack: int = 99

# HEALING items (Healing Seeds, Radiant Berries)
@export var hp_restore_percent: float = 0.3  # 30%
@export var full_restore: bool = false
@export var clears_status: bool = false

# OFFERING items
@export var infused_element: Global.ArtifactInfusion # from Elemental Artifact infusion, NONE by default

# EXPERIENCE items
@export var exp_points: int = 50

# ARTIFACT items (Elemental and Eternal)
@export var artifact_type: Global.ArtifactType  # ELEMENTAL, ETERNAL
@export var element: Global.LuminaeElement         # which element it belongs to
@export var element_bond_bonus: float = 0.0     # bonus when infused into matching Offering


func _validate_property(property: Dictionary) -> void:
	var healing_props = ["hp_restore_percent", "full_restore", "clears_status"]
	var offering_props = ["infused_element"]
	var experience_props = ["exp_points"]
	var artifact_props = ["artifact_type", "element", "element_bond_bonus"]

	if property.name in healing_props and item_type != Global.ItemType.HEALING:
		property.usage &= ~PROPERTY_USAGE_EDITOR

	if property.name in offering_props and item_type != Global.ItemType.OFFERING:
		property.usage &= ~PROPERTY_USAGE_EDITOR
	
	if property.name in experience_props and item_type != Global.ItemType.EXPERIENCE:
		property.usage &= ~PROPERTY_USAGE_EDITOR

	if property.name in artifact_props and item_type != Global.ItemType.ARTIFACT:
		property.usage &= ~PROPERTY_USAGE_EDITOR
