class_name InventoryItem
extends Resource

# Define the basic properties of an item
@export var id: String
@export var name: String
@export var weight: float
@export var value: int
@export var description: String
@export var quantity: int = 1
@export var category: String  # weapon, apparel, aid, misc, etc.
@export var icon: Texture2D

# Extra properties for equipment
@export var weapon_data: WeaponResource
#@export var apparel_data: 
@export var equippable: bool = false
@export var equipped: bool = false

func get_total_weight() -> float:
	return weight * quantity

# Serialize the item to a dictionary for saving
func to_dictionary() -> Dictionary:
	return {
	"id": id,
	"name": name,
	"weight": weight,
	"value": value,
	"description": description,
	"quantity": quantity,
	"category": category,
	"equippable": equippable,
	"equipped": equipped
	# Note: icon is not saved as it should be loaded from a predefined path
	}

# Create an item from a dictionary
static func from_dictionary(data: Dictionary) -> InventoryItem:
	var item = InventoryItem.new()
	item.id = data.get("id", "")
	item.name = data.get("name", "")
	item.weight = data.get("weight", 0.0)
	item.value = data.get("value", 0)
	item.description = data.get("description", "")
	item.quantity = data.get("quantity", 1)
	item.category = data.get("category", "MISC")
	item.equippable = data.get("equippable", false)
	item.equipped = data.get("equipped", false)
# Load icon based on item ID from your game's asset system
	return item
