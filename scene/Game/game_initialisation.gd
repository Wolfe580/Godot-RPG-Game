extends Node

# Autoload singleton
const UUID = preload("res://Autoload/UUID.gd")

# Node references
@onready var player: Player = $"../MainGame/Player"
@onready var pause_menu: Control = $"../MainGame/PauseMenu"
@onready var main_game: Node3D = $"../MainGame"
@onready var main_menu: Control = $"../MainMenu"
@onready var new_game_manager: Node = $"../NewGameManager" #not yet made

# Game state
var current_game_slot: int = -1
var current_game_data = null

# Constants
const DEFAULT_START_POSITION = Vector2(0, 0) 

# Signals
signal game_started(slot: int, game_data: Dictionary)
signal game_paused
signal game_resumed
signal save_loaded(save_data: Dictionary)
signal player_died
signal player_level_up(new_level: int)

# GameData class
class GameData:
	var metadata: Dictionary
	var character_data: Dictionary
	var world_state: Dictionary
	
	func _init():
		metadata = {}
		character_data = {}
		world_state = {
			"position": DEFAULT_START_POSITION,
			"inventory": [],
			"quests": {}
		}

# NewGameManager class
class NewGameManager:
	func create_new_game_save(slot: int, character_customization: Dictionary) -> GameData:
		var game_data = GameData.new()
		
		# Set up metadata
		game_data.metadata = {
			"slot": slot,
			"creation_date": Time.get_datetime_string_from_system(),
			"last_save": Time.get_datetime_string_from_system(),
			"play_time": 0
		}
		
		# Set up character data
		game_data.character_data = character_customization if not character_customization.is_empty() else {
			"name": "Player",
			"appearance": {},
			"stats": {
				"health": 100,
				"level": 1
			}
		}
		
		return game_data

# Initialize game state and signals
func _ready() -> void:
	if not SaveManager:  # Checks if autoload exists
		push_error("SaveManager singleton not found!")
		return
		
	_initialize_game_state()
	_connect_signals()

# Initialize game state
func _initialize_game_state() -> void:
	player.hide()  # Ensure player game isn't loaded (when persist save is set up this can be amended)
	player.hideplayerHUD()
	pause_menu.hide()  # Ensure the pause menu is hidden at the start
	main_menu.show()  # Load the main menu.
	print(UUID.v4())  # Setting values to be stored in profile files

# Connect signals
func _connect_signals() -> void:
	# Connect your signals here
	pass

# Create and start a new game
func create_and_start_new_game(slot: int, character_customization: Dictionary = {}) -> void:
	if not new_game_manager:
		push_error("NewGameManager not initialized!")
		return
		
	var new_game_data = new_game_manager.create_new_game_save(slot, character_customization)
	if not new_game_data:
		push_error("Failed to create new game data!")
		return
		
	# Save only metadata for now (adjust as needed)
	if SaveManager.save_game(slot, new_game_data.metadata):
		start_game(slot, new_game_data)
	else:
		push_error("Failed to save new game!")

# Start the game
func start_game(slot: int, game_data) -> void:
	current_game_slot = slot
	current_game_data = game_data
	
	# Here you would typically:
	# 1. Load the main game scene
	# 2. Initialize the player with game_data.character_data
	# 3. Set up the world state
	
	if game_data.character_data.is_empty():
		# No character data, show character creation
		show_character_creation()
	else:
		# Character exists, load into world
		load_into_world(game_data)

# Show character creation UI
func show_character_creation() -> void:
	# Implement your character creation UI logic here
	# Example:
	# var character_creation_scene = preload("res://scenes/character_creation.tscn").instantiate()
	# add_child(character_creation_scene)
	# character_creation_scene.connect("character_created", _on_character_created)
	pass

# Load into the game world
func load_into_world(game_data: GameData) -> void:
	# Implement your world loading logic here
	# Example:
	# var world_scene = preload("res://scenes/world.tscn").instantiate()
	# get_tree().root.add_child(world_scene)
	# world_scene.initialize(game_data)
	pass

# Handle character creation
func _on_character_created(character_data: Dictionary) -> void:
	if current_game_data:
		current_game_data.character_data = character_data
		# Save only metadata for now (adjust as needed)
		SaveManager.save_game(current_game_slot, current_game_data.metadata)
		load_into_world(current_game_data)

# Load a saved game
func load_game(slot: int) -> void:
	var game_data = SaveManager.load_game(slot)
	
	if game_data and game_data.size() > 0:
		start_game(slot, game_data)
		emit_signal("save_loaded", game_data)
	else:
		push_error("Failed to load save slot %d" % slot)

# Save the current game
func save_game() -> void:
	var current_slot = SaveManager.current_save_slot
	if current_slot <= 0:
		return
	
	var metadata = {
		"player_level": get_tree().get_first_node_in_group("player").level,
		"save_time": Time.get_datetime_string_from_system()
	}
	
	SaveManager.save_game(current_slot, metadata)
