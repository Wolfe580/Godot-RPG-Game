# Inventory.gd
extends Node

var inventory = {}

# Add an item to the inventory
func add_item(item_name: String, quantity: int = 1) -> void:
	if item_name in inventory:
		inventory[item_name] += quantity
	else:
		inventory[item_name] = quantity
	print("Added ", quantity, " of ", item_name, ". Inventory: ", inventory)

# Remove an item from the inventory
func remove_item(item_name: String, quantity: int = 1) -> void:
	if item_name in inventory:
		inventory[item_name] -= quantity
		if inventory[item_name] <= 0:
			inventory.erase(item_name)
		print("Removed ", quantity, " of ", item_name, ". Inventory: ", inventory)
	else:
		print("Item not found in inventory: ", item_name)

# Save inventory to a JSON file
func save_inventory(filename: String) -> void:
	var file = FileAccess.open(filename, FileAccess.WRITE)
	if file:
		var json_data = JSON.stringify(inventory)  # Convert inventory to JSON string
		file.store_string(json_data)  # Save JSON string to file
		file.close()
		print("Inventory saved to ", filename)
	else:
		print("Failed to save inventory. Error: ", FileAccess.get_open_error())

# Load inventory from a JSON file
func load_inventory(filename: String) -> void:
	if FileAccess.file_exists(filename):
		var file = FileAccess.open(filename, FileAccess.READ)
		if file:
			var json_data = file.get_as_text()  # Read JSON string from file
			var json = JSON.new()  # Create an instance of the JSON class
			var result = json.parse(json_data)  # Parse JSON string
			if result.error == OK:
				inventory = result.result  # Set inventory to the parsed dictionary
				print("Inventory loaded from ", filename)
			else:
				print("Failed to parse JSON. Error: ", result.error_string)
			file.close()
		else:
			print("Failed to load inventory. Error: ", FileAccess.get_open_error())
	else:
		print("Inventory file does not exist: ", filename)
