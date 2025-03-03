extends Node

const UUID = preload("res://Autoload/UUID.gd")
const SAVE_PATH = "user://Player_profiles.cfg"

# Node references
@onready var player: Player = $"../MainGame/Player"
@onready var pause_menu: Control = $"../MainGame/PauseMenu"
@onready var main_game: Node3D = $"../MainGame"
@onready var main_menu: Control = $"../MainMenu"
@onready var save_manager: Node = $"/root/SaveManager"
@onready var new_game_manager: Node = $"../NewGameManager"
@onready var current_slot: int
# Signals
signal game_started(slot: int, game_data: Dictionary)
signal game_paused
signal game_resumed
signal save_loaded(save_data: Dictionary)
signal player_died
signal player_level_up(new_level: int)

func _ready() -> void:
	_initialize_game_state()
	_connect_signals()

func _initialize_game_state() -> void:
	player.hide()
	player.hideplayerHUD()
	pause_menu.hide()
	main_menu.show()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func setup_world() -> void:
	player.show()
	player.showplayerHUD()
	main_menu.hide()
	get_tree().paused = false

func _process(_delta):
	if Input.is_action_just_pressed("Pause"):
		toggle_pause()

func toggle_pause():
	if get_tree().paused:
		print("Unpausing the game")
		get_tree().paused = false
		pause_menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		print("Pausing the game")
		get_tree().paused = true
		pause_menu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _connect_signals() -> void:
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		if player_node.has_signal("player_died"):
			player_node.connect("player_died", _on_player_died)
		if player_node.has_signal("level_up_achieved"):
			player_node.connect("level_up_achieved", _on_player_level_up)

# Game State Management
func create_and_start_new_game(slot: int, character_customization: Dictionary = {}) -> void:
	if not new_game_manager:
		push_error("NewGameManager not initialized!")
		return
		
	var new_game_data = new_game_manager.create_new_game_save(slot, character_customization)
	if not new_game_data:
		push_error("Failed to create new game data!")
		return
		
	save_manager.save_game(slot, new_game_data.metadata, new_game_data)
	start_game(slot, new_game_data)

func start_game(slot: int, game_data: Dictionary) -> void:
	if game_data.has("game_state"):
		var state = game_data["game_state"]
		if state.has("player"):
			main_game.apply_player_data(state.player)
		if state.has("world"):
			main_game.apply_world_data(state.world)
	
	main_menu.hide()
	main_game.show()
	setup_world()
	ready.emit()
	emit_signal("game_started", slot, game_data)

func load_game(slot: int) -> void:
	print("Starting load_game with slot:", slot)
	
	if not save_manager:
		push_error("save_manager is null")
		return
		
	var game_data = save_manager.load_game(slot)
	print("Loaded game data:", game_data)
	current_slot=slot
	if game_data and game_data.size() > 0:
		print("Starting game with data")
		if has_method("start_game"):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			start_game(slot, game_data)
			emit_signal("save_loaded", game_data)
		else:
			push_error("start_game method not found")
	else:
		push_error("Failed to load save slot %d" % slot)

# Save System
func save_game(slot: int) -> void:
	var current_slot = slot
	if slot <= 0:
		return
	var metadata = {
		"player_level": get_tree().get_first_node_in_group("player").level,
		"save_time": Time.get_datetime_string_from_system()
	}
	save_manager.save_game(current_slot, metadata)
	
func apply_save_data(save_data: Dictionary) -> void:
	if save_data.has("player"):
		var player_node = get_tree().get_first_node_in_group("player")
		if player_node:
			apply_player_data(player_node, save_data.player)

func apply_player_data(player_node: Node, player_data: Dictionary) -> void:
	print("Applying player data: ", player_data)
	if player_data.has("position"):
		print("Setting player position to: ", player_data.position)
		if player_data.position is Vector3:
			player_node.global_position = player_data.position
		elif player_data.position is Dictionary:
			player_node.global_position = Vector3(
				player_data.position.x,
				player_data.position.y,
				player_data.position.z
			)
	
	# Apply other player properties
	for property in player_data:
		if property != "position" and player_node.has(property):
			player_node.set(property, player_data[property])

func apply_default_data() -> void:
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		player_node.set_health(100)
		player_node.set_max_health(100)
		player_node.set_stamina(100)
		player_node.set_max_stamina(100)
		player_node.set_level(1)
		player_node.set_experience(0)
		player_node.set_experience_to_next_level(100)

func auto_save() -> void:
	save_game(current_slot)
	print("Auto-saved game to slot ", save_manager.current_save_slot)

# Event Handlers
func _on_player_died() -> void:
	emit_signal("player_died")
	# Implementation for handling player death

func return_to_main_menu():
	toggle_pause()
	# Hide the pause menu
	if main_game.has_node("PauseMenu"):
		print("Hiding pause menu")
		main_game.get_node("PauseMenu").hide()
	# Hide the main game
	if main_game:
		print("Hiding main game")
		main_game.hide()
	# Show the main menu
	if main_menu:
		print("Displaying main menu")
		player.hideplayerHUD()
		main_menu.show()
		main_menu.reset_main_menu()
	
	# Hide the mouse cursor (optional, depending on your main menu design)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_player_level_up(new_level: int) -> void:
	emit_signal("player_level_up", new_level)
	save_game(current_slot)
