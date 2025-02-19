# PauseScreen.gd
extends Control

@onready var player: Player = $"../Player"
@onready var game_manager = $"../../GameManager"
@onready var pause_menu = $PauseMenuLayout
@onready var save_button = $PauseMenuLayout/SaveGameButton
@onready var resume_button = $PauseMenuLayout/ResumeButton
@onready var load_button = $PauseMenuLayout/LoadGameButton
@onready var exit_button =$PauseMenuLayout/ExitGameButton
@onready var save_menu = $PauseMenuSave
@onready var save_slot1 =$PauseMenuSave/SaveSlot1
@onready var save_slot2 =$PauseMenuSave/SaveSlot2
@onready var save_slot3 =$PauseMenuSave/SaveSlot3
@onready var save_return =$PauseMenuSave/Return
@onready var load_menu =$PauseMenuLoad
@onready var load_slot1 =$PauseMenuLoad/LoadSlot1
@onready var load_slot2 =$PauseMenuLoad/LoadSlot2
@onready var load_slot3 =$PauseMenuLoad/LoadSlot3
@onready var load_return =$PauseMenuLoad/ReturnLoad
@onready var game_state


##Functions
#Readying pause menu
func _ready():
	#Hooking up button presses to relevant logic.
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED) #Make the mouse visible again so that the user can access the buttons
	setbuttons()
	save_menu.hide()
	load_menu.hide()

func setbuttons():
	resume_button.connect("pressed", self._on_resume_pressed)
	save_button.connect("pressed", self._on_save_pressed)
	load_button.connect("pressed", self._on_load_pressed)
	exit_button.connect("pressed", self._on_quit_pressed)
	save_slot1.connect("pressed",self._on_save1_pressed)
	save_slot2.connect("pressed",self._on_save2_pressed)
	save_slot3.connect("pressed",self._on_save3_pressed)
	save_return.connect("pressed",self._on_savereturn_pressed)
	load_slot1.connect("pressed",self._on_load1_pressed)
	load_slot2.connect("pressed",self._on_load2_pressed)
	load_slot3.connect("pressed",self._on_load3_pressed)
	load_return.connect("pressed",self._on_loadreturn_pressed)
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
	pause_menu.hide()
	save_menu.show()

func _on_load_pressed():
	print("Load Game pressed")
	pause_menu.hide()
	load_menu.show()
	# load_game()

func _on_load1_pressed():
	print("loaded slot 1")
	game_state = SaveManager.load_game(1)
	#SaveManager.load_game()
func _on_load2_pressed():
	print("loaded slot 2")
	game_state = SaveManager.load_game(2)
func _on_load3_pressed():
	print("loaded slot 3")
	game_state = SaveManager.load_game(3)
func _on_loadreturn_pressed():
	load_menu.hide()
	pause_menu.show()

func _on_save1_pressed():
	print("Saved slot 1")
	#SaveManager.save_game(1, {"level": "forest", "difficulty": "hard"})
func _on_save2_pressed():
	print("Saved slot 2")
	player.save_game(2)
func _on_save3_pressed():
	print("Saved slot 3")
	player.save_game(3)
func _on_savereturn_pressed():
	save_menu.hide()
	pause_menu.show()

func _on_quit_pressed():
	#I want to change this later to provide the user a prompt that they can either exit to main menu or straight to desktop
	print("Quit to Main Menu pressed")
	get_tree().paused = false  # Unpause the game
	game_manager.return_to_main_menu()
