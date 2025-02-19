extends Node

# Constants
const SAVE_DIR = "user://saves/"
const SAVE_EXTENSION = ".save"
const MAX_SAVE_SLOTS = 10

# Save metadata
var save_metadata = {
	"timestamp": Time.get_unix_time_from_system(),
	"version": ProjectSettings.get_setting("application/config/version", "1.0"),
	"custom_metadata":[],
	"player_name": "Default",
	"difficulty": 1,
	"game_time": 0,
	"character_level": 1,
	"location": "starting_area"
	}

var current_save_slot = 0

func _ready():
	# Create saves directory if it doesn't exist
	create_save_directory()
	load_save_metadata() #not yet implemented

func create_save_directory():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(SAVE_DIR):
		dir.make_dir(SAVE_DIR)

func get_save_path(slot: int) -> String:
	return SAVE_DIR + "save_slot_" + str(slot) + SAVE_EXTENSION

func save_game(slot: int, metadata: Dictionary = {}) -> Error:
	if slot < 1 or slot > MAX_SAVE_SLOTS:
		push_error("Invalid save slot: " + str(slot))
		return ERR_PARAMETER_RANGE_ERROR
	
	var save_data = {
		"metadata": {
			"timestamp": Time.get_unix_time_from_system(),
			"version": ProjectSettings.get_setting("application/config/version", "1.0"),
			"custom_metadata": metadata
		},
		"game_state": collect_game_state()
	}
	
	var json_string = JSON.stringify(save_data)
	var save_file = FileAccess.open(get_save_path(slot), FileAccess.WRITE)
	if save_file == null:
		return FileAccess.get_open_error()
	
	save_file.store_string(json_string)
	current_save_slot = slot
	update_save_metadata(slot, save_data.metadata)
	return OK

func load_game(slot: int) -> Dictionary:
	if slot < 1 or slot > MAX_SAVE_SLOTS:
		print("Invalid load slot: " + str(slot))
		return {}
	
	var save_file = FileAccess.open(get_save_path(slot), FileAccess.READ)
	if save_file == null:
		print("No save file found in slot: " + str(slot))
		return {}
	
	var json_string = save_file.get_as_text()
	print("Loading save file content: ", json_string) # Debug the file content
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("Failed to parse save file. Error: " + json.get_error_message() + " at line " + str(json.get_error_line()))
		return {}
	
	var save_data = json.get_data()
	if not save_data.has("game_state"):
		print("Save file missing game_state")
		return {}
		
	current_save_slot = slot
	return save_data.game_state

func collect_game_state() -> Dictionary:
	# reference important nodes
	var player = get_tree().get_first_node_in_group("player")
	var world = get_tree().get_first_node_in_group("world")
	
	var state = {
		"player": collect_node_state(player),
		"world": collect_node_state(world),
		"entities": collect_entities_state(),
		"inventory": collect_inventory_state(),
		"quests": collect_quest_state(),
		"time": collect_time_state()
	}
	
	return state

func collect_node_state(node: Node) -> Dictionary:
	if not node:
		return {}
	
	var state = {}
	
	# Save transform for spatial nodes
	if node is Node3D:
		state.position = node.global_position
		state.rotation = node.global_rotation
	
	# Save custom properties marked for saving
	if node.has_method("get_save_properties"):
		state.merge(node.get_save_properties())
	
	return state

func collect_entities_state() -> Array:
	var entities = get_tree().get_nodes_in_group("save_entity")
	var entities_data = []
	
	for entity in entities:
		var entity_data = {
			"scene": entity.scene_file_path,
			"state": collect_node_state(entity)
		}
		entities_data.append(entity_data)
	
	return entities_data

func collect_inventory_state() -> Dictionary:
	var inventory = get_tree().get_first_node_in_group("inventory")
	if inventory and inventory.has_method("get_save_state"):
		return inventory.get_save_state()
	return {}

func collect_quest_state() -> Dictionary:
	var quest_manager = get_tree().get_first_node_in_group("quest_manager")
	if quest_manager and quest_manager.has_method("get_save_state"):
		return quest_manager.get_save_state()
	return {}

func collect_time_state() -> Dictionary:
	var time_manager = get_tree().get_first_node_in_group("time_manager")
	if time_manager and time_manager.has_method("get_save_state"):
		return time_manager.get_save_state()
	return {}

func load_save_metadata():
	save_metadata.clear()
	
	for slot in range(1, MAX_SAVE_SLOTS + 1):
		var save_file = FileAccess.open(get_save_path(slot), FileAccess.READ)
		if save_file != null:
			var json_string = save_file.get_as_text()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var data = json.get_data()
				save_metadata[slot] = data.metadata
			return {
			"timestamp": Time.get_unix_time_from_system(),
			"version": ProjectSettings.get_setting("application/config/version", "1.0"),
			"custom_metadata": {
				"player_name": "Default",
				"difficulty": 1,
				"game_time": 0,
				"character_level": 1,
				"location": "starting_area"
			}
		}

func update_save_metadata(slot: int, metadata: Dictionary):
	save_metadata[slot] = metadata

func get_save_metadata(slot: int) -> Dictionary:
	# Return empty dictionary if no save exists	
	print("GS Metadata:")
	print(slot)
	if not save_exists(slot):
		return {}
	# Return basic metadata structure if save exists but is empty
	return {
		"timestamp": Time.get_unix_time_from_system(),
		"custom_metadata": {
			"level": 1,
			"location": "Starting Area"
		}
	}

func get_save_slots() -> Array:
	var slots = []
	for slot in range(1, MAX_SAVE_SLOTS + 1):
		if save_exists(slot):
			slots.append(slot)
	return slots

func delete_save(slot: int) -> Error:
	if slot < 1 or slot > MAX_SAVE_SLOTS:
		return ERR_PARAMETER_RANGE_ERROR
	
	var dir = DirAccess.open("user://")
	var path = get_save_path(slot)
	
	if FileAccess.file_exists(path):
		var error = dir.remove(path)
		if error == OK:
			save_metadata.erase(slot)
		return error
	
	return OK

func save_exists(slot: int) -> bool:
	print("save exists:")
	print(slot)
	if slot < 1 or slot > MAX_SAVE_SLOTS:
		return false
	print("we're in")
	return FileAccess.file_exists(get_save_path(slot))
	
