# GameManager.gd
extends Node

##References to other screens
@onready var player: Player = $"../MainGame/Player"  
@onready var pause_menu : Control = $"../MainGame/PauseMenu" 
@onready var main_game : Node3D = $"../MainGame"
@onready var main_menu : Control = $"../MainMenu"

##Functions
#Readying game state
func _ready():
	player.hide() #Ensure player game isnt loaded (when persist save is set up this can be amended).
	player.health_bar.hide()
	player.ammo_bar.hide()
	pause_menu.hide()  # Ensure the pause menu is hidden at the start
	main_menu.show() #Load the main menu.

#Obtaining input
func _process(_delta):
	if Input.is_action_just_pressed("Pause"):
		toggle_pause()

func _input(event):
	if get_tree().paused:
		# If the game is paused, let the UI handle input first
		if pause_menu.visible:
			pause_menu._gui_input(event)
			if event is InputEventMouseButton and event.pressed:
				get_viewport().set_input_as_handled()


# Start the game (called from MainMenu)
func start_game(profile_name: String):
	print("Starting game with profile: ", profile_name)
	if main_game:
		main_game.show()  # Show the MainGame
		player.show()
		player.health_bar.show()
		player.ammo_bar.show()
		main_menu.hide()  # Hide the MainMenu
	get_tree().paused = false  # Unpause the game
		
	# Load profile data into MainGame
	if main_game.has_method("load_profile"):
		main_game.load_profile(profile_name)

# Return to the main menu (called from PauseMenu)
func return_to_main_menu():
	toggle_pause()
	if main_game:
		print('Hiding maingame')
		main_game.hide()  # Hide the MainGame
	if main_game.has_node("PauseMenu"):
		print("hiding pause menu")
		main_game.get_node("PauseMenu").hide()  # Hide the PauseMenu
	if main_menu:
		print("displaying main menu")
		main_menu.show()
		

#Toggling pause menu
func toggle_pause():
	if get_tree().paused:
		print("Unpausing the game")
		get_tree().paused = false
		pause_menu.hide()
	else:
		print("Pausing the game")
		get_tree().paused = true
		pause_menu.show()
