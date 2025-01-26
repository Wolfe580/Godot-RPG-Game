# MainMenu.gd
extends Control

@onready var game_manager=$"../GameManager"

##Functions
#Readying main menu
func _ready():
	#Hooking up button presses to relevant logic.
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED) #Make the mouse visible again so that the user can access the buttons
	$MainMenuLayout/NewGameButton.connect("pressed", self._on_new_game_pressed)
	$MainMenuLayout/LoadGameButton.connect("pressed", self._on_load_game_pressed)
	$MainMenuLayout/SettingsButton.connect("pressed", self._on_settings_pressed)
	$MainMenuLayout/ExitButton.connect("pressed", self._on_exit_pressed)
	
	#Pause game while you are in main menu
	get_tree().paused = true

func _on_new_game_pressed():
	print("New Game pressed")
	var profile_name = "Profile1" #replace later with Userinput
	create_profile(profile_name)
	game_manager.start_game(profile_name)

func _on_load_game_pressed():
	print("Load Game pressed")
	var profile_name = "Profile1"  # Replace with dynamic selection (e.g., dropdown)
	var profile_data = load_profile(profile_name)
	if profile_data:
		game_manager.start_game(profile_name)

func _on_settings_pressed():
	print("Settings pressed")
	# Work on allowing the user to edit settings such as user controls and resolution.
	# Example: get_tree().change_scene_to_file("res://scene/settings.tscn")

func _on_exit_pressed():
	print("Exit pressed")
	get_tree().quit()

func create_profile(profile_name: String):
	var config = ConfigFile.new()
	# Set default values for a new profile
	config.set_value(profile_name, "player_name", "Player")
	config.set_value(profile_name, "health", 100)
	config.set_value(profile_name, "level", 1)
	config.set_value(profile_name, "position", Vector3(0, 0, 0))
	config.set_value(profile_name, "inventory", {})
	# Save the profile to a file
	var error = config.save("user://" + profile_name + ".cfg")
	if error == OK:
		print("Profile created: ", profile_name)
	else:
		print("Failed to create profile: ", profile_name)


func load_profile(profile_name: String) -> Dictionary:
	var config = ConfigFile.new()
	var error = config.load("user://" + profile_name + ".cfg")
	 
	if error == OK:
		print("Profile loaded: ", profile_name)
	# Return the profile data
		return {
			"player_name": config.get_value(profile_name, "player_name", "Player"),
			"health": config.get_value(profile_name, "health", 100),
			"level": config.get_value(profile_name, "level", 1),
			"position": config.get_value(profile_name, "position", Vector3(0, 0, 0)),
			"inventory": config.get_value(profile_name, "inventory", {})
		}
	else:
		print("Failed to load profile: ", profile_name)
		return {}

func start_game(profile_name: String):
	print("Starting game with profile: ", profile_name)
	# Unpause the game tree
	get_tree().paused = false
	 # Load the game scene
	var game_scene = load("res://scene/game.tscn").instantiate()
	# Pass the profile data to the game scene
	game_scene.profile_data = load_profile(profile_name)
	# Switch to the game scene
	get_tree().root.add_child(game_scene)
	get_tree().current_scene = game_scene
	# Hide the main menu
	hide()
