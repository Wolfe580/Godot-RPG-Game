extends Node

# Constants
const SAVE_DIR = "user://saves/"
const SAVE_EXTENSION = ".save"
const MAX_SAVE_SLOTS = 10

# Save metadata
var save_metadata = {}
var current_save_slot = 0

func _ready():
	create_save_directory()
	load_save_metadata() 

# Helper Functions
func create_save_directory():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(SAVE_DIR):
		dir.make_dir(SAVE_DIR)

func create_metadata(custom_metadata: Dictionary = {}) -> Dictionary:
	return {
		"timestamp": Time.get_unix_time_from_system(),
		"version": ProjectSettings.get_setting("application/config/version", "1.0"),
		"custom_metadata": custom_metadata,
		"player_name": "Default",
		"difficulty": 1,
		"game_time": 0,
		"character_level": 1,
		"location": "starting_area"
	}

func is_valid_slot(slot: int) -> bool:
	return slot >= 1 and slot <= MAX_SAVE_SLOTS

func open_file_for_writing(path: String) -> FileAccess:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open file for writing: " + path)
	return file

func open_file_for_reading(path: String) -> FileAccess:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file for reading: " + path)
	return file

func get_save_path(slot: int) -> String:
	return SAVE_DIR + "save_slot_" + str(slot) + SAVE_EXTENSION

func save_exists(slot: int) -> bool:
	return is_valid_slot(slot) and FileAccess.file_exists(get_save_path(slot))

# Save and Load Functions
func save_game(slot: int, metadata: Dictionary = {}) -> Error:
	print("Attempting to save game in slot: ", slot)#debug
	if not is_valid_slot(slot):
		push_error("Invalid save slot: " + str(slot))
		return ERR_PARAMETER_RANGE_ERROR
	
	var save_data = {
		"metadata": {
			"timestamp": Time.get_unix_time_from_system(),
			"version": ProjectSettings.get_setting("application/config/version", "1.0"),
			"custom_metadata": metadata
		},
		"game_state": collect_game_state()}
	print("Save data created: ", save_data)
	
	var json_string = JSON.stringify(save_data)
	var save_file = open_file_for_writing(get_save_path(slot))
	if save_file == null:
		return FileAccess.get_open_error()
	
	save_file.store_string(json_string)
	current_save_slot = slot
	update_save_metadata(slot, save_data.metadata)
	return OK

func apply_loaded_state(slot: int, game_state: Dictionary) -> void:
	if not game_state:
		print("No game state to load")
		return
	
	# Apply player state
	var player = get_tree().get_first_node_in_group("player")
	if game_state.has("player") and player and player.has_method("apply_save_state"):
		player.apply_save_state(game_state.player, slot)
		print("Player position after load: ", player.global_position)
	
	# Apply other states
	for group in ["world", "inventory", "quest_manager", "time_manager"]:
		apply_state_to_node(group, game_state.get(group, {}))
	# Handle entities separately
	apply_entities_state(game_state.get("entities", []))

func apply_state_to_node(group: String, state: Dictionary) -> void:
	var node = get_tree().get_first_node_in_group(group)
	if node and node.has_method("apply_save_state"):
		node.apply_save_state(state)

func apply_entities_state(entities: Array) -> void:
	# Clear existing entities
	for entity in get_tree().get_nodes_in_group("save_entity"):
		entity.queue_free()
	
	# Spawn saved entities
	for entity_data in entities:
		if entity_data.has("scene"):
			var scene = load(entity_data.scene)
			if scene:
				var entity = scene.instantiate()
				get_tree().current_scene.add_child(entity)
				if entity.has_method("apply_save_state"):
					entity.apply_save_state(entity_data.state)

func collect_game_state() -> Dictionary:
	var state = {}
	# Collect state from nodes
	for group in ["player", "world", "inventory", "quest_manager", "time_manager", "position"]:
		state[group] = collect_state_from_node(group)
	# Collect entities state
	state["entities"] = collect_entities_state()
	return state

func collect_state_from_node(group: String) -> Dictionary:
	var node = get_tree().get_first_node_in_group(group)
	if node and node.has_method("get_save_state"):
		return node.get_save_state()
	return {}

func collect_entities_state() -> Array:
	var entities_data = []
	for entity in get_tree().get_nodes_in_group("save_entity"):
		entities_data.append({
			"scene": entity.scene_file_path,
			"state": collect_node_state(entity)
		})
	return entities_data

func collect_node_state(node: Node) -> Dictionary:
	if not node:
		return {}
	
	var state = {}
	
	# Save transform for spatial nodes
	if node is Node3D:
		state.position = node.global_position
		state.rotation = node.global_rotation
		print("Saving position: ", state.position)
	# Save custom properties marked for saving
	if node.has_method("get_save_properties"):
		state.merge(node.get_save_properties())
	
	return state

# Metadata Functions
func load_save_metadata():
	save_metadata.clear()
	for slot in range(1, MAX_SAVE_SLOTS + 1):
		var save_file = open_file_for_reading(get_save_path(slot))
		if save_file != null:
			var json_string = save_file.get_as_text()
			var json = JSON.new()
			if json.parse(json_string) == OK:
				save_metadata[slot] = json.get_data().metadata

func update_save_metadata(slot: int, metadata: Dictionary):
	save_metadata[slot] = metadata

func get_save_metadata(slot: int) -> Dictionary:
	if not save_exists(slot):
		return {}
	return save_metadata.get(slot, create_metadata())

func get_save_slots() -> Array:
	var slots = []
	for slot in range(1, MAX_SAVE_SLOTS + 1):
		if save_exists(slot):
			slots.append(slot)
	return slots

func load_game(slot: int) -> Dictionary:
	print("Attempting to load game from slot: ", slot)
	
	var save_file = FileAccess.open(get_save_path(slot), FileAccess.READ)
	if save_file == null:
		print("No save file found in slot: " + str(slot))
		return {}
	
	var json_string = save_file.get_as_text()
	print("Loading save file content: ", json_string)
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("Failed to parse save file")
		return {}
	
	var save_data = json.get_data()
	if not save_data.has("game_state"):
		print("Save file missing game_state")
		return {}
		
	current_save_slot = slot
	var game_state = save_data.game_state
	print("Loaded game state: ", game_state)
	apply_loaded_state(slot, game_state)
	return game_state

func delete_save(slot: int) -> Error:
	if not is_valid_slot(slot):
		return ERR_PARAMETER_RANGE_ERROR
	
	var dir = DirAccess.open("user://")
	var path = get_save_path(slot)
	
	if FileAccess.file_exists(path):
		var error = dir.remove(path)
		if error == OK:
			save_metadata.erase(slot)
		return error
	
	return OK
