extends Node

# Save file path
var save_path = "user://save_game.cfg"

# Save game data
func save_game(player_data: Dictionary, world_data: Dictionary, entities_data: Array) -> void:
	var config = ConfigFile.new()

	# Save player data
	config.set_value("player", "data", player_data)

	# Save world data
	config.set_value("world", "data", world_data)

	# Save entities data
	for i in range(entities_data.size()):
		config.set_value("entities", "entity_" + str(i), entities_data[i])

	# Save the file
	var error = config.save(save_path)
	if error == OK:
		print("Game saved successfully!")
	else:
		print("Failed to save game. Error code: ", error)

# Load game data
func load_game() -> Dictionary:
	var config = ConfigFile.new()
	var error = config.load(save_path)
	if error != OK:
		print("Failed to load game. Error code: ", error)
		return {}

	# Load player data
	var player_data = config.get_value("player", "data", {})

	# Load world data
	var world_data = config.get_value("world", "data", {})

	# Load entities data
	var entities_data = []
	for section in config.get_section_keys("entities"):
		entities_data.append(config.get_value("entities", section))

	return {
		"player": player_data,
		"world": world_data,
		"entities": entities_data
	}
