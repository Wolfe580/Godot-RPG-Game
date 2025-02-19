extends Node3D

@onready var player: Player = $"../Player"
@onready var save_manager = $"/root/SaveManager"  # Reference to autoloaded SaveManager

# Current save slot and game state
var current_save_slot: int = -1
var auto_save_interval: float = 300.0  # 5 minutes
var time_since_last_save: float = 0.0

func _ready():
	# Initialize the game
	setup_game()
	# Connect signals
	connect_signals()

func _process(delta):
	# Handle auto-save
	time_since_last_save += delta
	if time_since_last_save >= auto_save_interval:
		auto_save()
		time_since_last_save = 0.0

func setup_game():
	# Initialize player with default values in case no save data exists
	var default_player_data = {
		"stats": {
			"health": 100,
			"max_health": 100,
			"stamina": 100,
			"max_stamina": 100,
			"level": 1,
			"experience": 0,
			"experience_to_next_level": 100
		},
		"transform": {
			"position": Vector3.ZERO,
			"rotation": Vector3.ZERO
		},
		"inventory": {}
	}
	
	# Apply saved data if it exists
	if current_save_slot > 0:
		var save_data = save_manager.load_game(current_save_slot)
		if save_data.size() > 0:
			apply_save_data(save_data)
		else:
			apply_player_data(default_player_data)
	else:
		apply_player_data(default_player_data)

func apply_player_data(player_data: Dictionary):
	if !player:
		return
	
	# Apply stats
	if player_data.has("stats"):
		var stats = player_data.stats
		# Check if player has the necessary methods to update stats
		if player.has_method("set_health"):
			player.set_health(stats.health)
		if player.has_method("set_max_health"):
			player.set_max_health(stats.max_health)
		if player.has_method("set_stamina"):
			player.set_stamina(stats.stamina)
		if player.has_method("set_max_stamina"):
			player.set_max_stamina(stats.max_stamina)
		if player.has_method("set_level"):
			player.set_level(stats.level)
		if player.has_method("set_experience"):
			player.set_experience(stats.experience)
		if player.has_method("set_experience_to_next_level"):
			player.set_experience_to_next_level(stats.experience_to_next_level)
	
	# Apply position and rotation
	if player_data.has("transform"):
		player.global_position = Vector3(
			player_data.transform.position.x,
			player_data.transform.position.y,
			player_data.transform.position.z
		)
		player.global_rotation = Vector3(
			player_data.transform.rotation.x,
			player_data.transform.rotation.y,
			player_data.transform.rotation.z
		)
	
	# Apply inventory
	if player_data.has("inventory") and player.has_method("add_item"):
		for item_id in player_data.inventory:
			player.add_item(item_id, player_data.inventory[item_id])

func connect_signals():
	# Connect to player signals
	if player:
		player.connect("player_died", _on_player_died)
		player.connect("level_up_achieved", _on_player_level_up)

func apply_save_data(save_data: Dictionary):
	if save_data.has("player"):
		apply_player_data(save_data.player)
	
	# Apply world state if it exists
	if save_data.has("world"):
		apply_world_data(save_data.world)
	
	# Apply any other game state data
	if save_data.has("game_state"):
		apply_game_state(save_data.game_state)


func apply_world_data(world_data: Dictionary):
	# Apply world-specific data (time of day, weather, etc.)
	pass

func apply_game_state(game_state: Dictionary):
	# Apply any additional game state data
	pass

func save_game():
	if current_save_slot <= 0:
		return
	
	var save_data = collect_save_data()
	var metadata = {
		"level": player.player_data.stats.level,
		"location": get_current_location_name(),
		"play_time": get_play_time()
	}
	
	save_manager.save_game(current_save_slot, metadata, save_data)

func auto_save():
	if current_save_slot > 0:
		save_game()
		print("Auto-saved game to slot ", current_save_slot)

func collect_save_data() -> Dictionary:
	var save_data = {
		"player": player.get_save_properties(),
		"world": collect_world_data(),
		"game_state": collect_game_state()
	}
	return save_data

func collect_world_data() -> Dictionary:
	# Collect world state data
	return {
		"time_of_day": get_time_of_day(),
		"current_zone": get_current_zone()
	}

func collect_game_state() -> Dictionary:
	# Collect any additional game state data
	return {}

func get_current_location_name() -> String:
	# Implement based on your zone system
	return "Unknown Location"

func get_play_time() -> float:
	# Implement based on your time tracking system
	return 0.0

func get_time_of_day() -> float:
	# Implement based on your day/night system
	return 0.0

func get_current_zone() -> String:
	# Implement based on your zone system
	return "unknown_zone"

# Signal handlers
func _on_player_died():
	# Handle player death (reload last save, respawn, etc.)
	pass

func _on_player_level_up(new_level: int):
	# Save game on level up
	save_game()

# Input handling
func _unhandled_input(event):
	if event.is_action_pressed("quick_save"):
		save_game()
		print("Game saved to slot ", current_save_slot)
	elif event.is_action_pressed("quick_load") and current_save_slot > 0:
		var save_data = save_manager.load_game(current_save_slot)
		if save_data.size() > 0:
			apply_save_data(save_data)
			print("Game loaded from slot ", current_save_slot)
