# PauseScreen.gd
extends Control

@onready var player: Player = $"../Player"
@onready var game_manager = $"../../GameManager"
@onready var save_button = $PauseMenuLayout/SaveGameButton

##Functions
#Readying pause menu
func _ready():
	#Hooking up button presses to relevant logic.
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED) #Make the mouse visible again so that the user can access the buttons
	$PauseMenuLayout/ResumeButton.connect("pressed", self._on_resume_pressed)
	save_button.connect("pressed", self._on_save_pressed)
	$PauseMenuLayout/LoadGameButton.connect("pressed", self._on_load_pressed)
	$PauseMenuLayout/ExitGameButton.connect("pressed", self._on_quit_pressed)

#User input
func _gui_input(event):
	if Input.is_action_just_pressed("Pause"):
		_on_resume_pressed()

func _on_resume_pressed():
	print("Resume pressed")
	player.showplayerHUD()
	hide()  # Hide the pause screen
	get_tree().paused = false  # Unpause the game
	get_viewport().set_input_as_handled()

func _on_save_pressed():
	print("Save Game pressed")
	if get_tree().current_scene.has_method("save_game"):
		get_tree().current_scene.save_game("Profile1") #change later to dynamically process profile following refinement of player class.
	else:
		print("Error: Game scene does not have save game method.")

func _on_load_pressed():
	print("Load Game pressed")
# Call load function when I have worked on persisted settings and character profiles
	# load_game()

func _on_quit_pressed():
	#I want to change this later to provide the user a prompt that they can either exit to main menu or straight to desktop
	print("Quit to Main Menu pressed")
	get_tree().paused = false  # Unpause the game
	game_manager.return_to_main_menu()
