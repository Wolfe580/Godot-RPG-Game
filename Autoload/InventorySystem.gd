class_name InventorySystem
extends Node

signal inventory_changed
signal weight_changed

var items: Dictionary = {}  # Dictionary of item_id: Item
var max_weight: float = 200.0
var current_weight: float = 0.0

# Add an item to the inventory
func add_item(item: InventoryItem, amount: int = 1) -> bool:
	if item == null:
		return false
		
	# Check if adding this would exceed weight limit
	if current_weight + (item.weight * amount) > max_weight:
		return false
		
	if items.has(item.id):
		items[item.id].quantity += amount
	else:
		var new_item = item.duplicate()
		new_item.quantity = amount
		items[item.id] = new_item
	
	current_weight += item.weight * amount
	emit_signal("inventory_changed")
	emit_signal("weight_changed", current_weight)
	return true

# Remove an item from inventory
func remove_item(item_id: String, amount: int = 1) -> bool:
	if not items.has(item_id):
		return false
		
	var item = items[item_id]
	if item.quantity < amount:
		return false
		
	item.quantity -= amount
	current_weight -= item.weight * amount
	
	if item.quantity <= 0:
		items.erase(item_id)
	
	emit_signal("inventory_changed")
	emit_signal("weight_changed", current_weight)
	return true

# Get items by category
func get_items_by_category(category: String) -> Array:
	var category_items = []
	for item in items.values():
		if item.category == category:
			category_items.append(item)
	return category_items
