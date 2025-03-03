# PauseScreen.gd
extends Control

@onready var player: Player = $"../Player"
@onready var game_manager = $"../../GameManager"
@onready var save_manager = $"/root/SaveManager"
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

func _on_save_button_pressed():
	update_save_slots()
	pause_menu.hide()
	save_menu.show()

func _on_load_button_pressed():
	update_save_slots()
	pause_menu.hide()
	load_menu.show()

func _on_back_button_pressed():
	save_menu.hide()
	load_menu.hide()
	pause_menu.show()

func update_save_slots():
	for slot in range(1, 4):
		var metadata = save_manager.get_save_metadata(slot)
		update_slot_button(slot, metadata, true)  # true for save menu
		update_slot_button(slot, metadata, false) # false for load menu

func update_slot_button(slot: int, metadata: Dictionary, is_save_menu: bool):
	var button = get_node("%sMenu/Slot%dButton" % ["Save" if is_save_menu else "Load", slot])
	
	if metadata.size() > 0:
		var timestamp = metadata.get("timestamp", 0)
		var datetime = Time.get_datetime_dict_from_unix_time(timestamp)
		var date_string = "%d/%d/%d %02d:%02d" % [
			datetime.month, datetime.day, datetime.year,
			datetime.hour, datetime.minute
		]
		var custom_metadata = metadata.get("custom_metadata", {})
		var level = custom_metadata.get("level", 1)
		var location = custom_metadata.get("location", "Unknown")
		button.text = "Level %d - %s\n%s" % [level, location, date_string]
		button.disabled = false if is_save_menu else false
	else:
		button.text = "Empty Save Slot"
		button.disabled = false if is_save_menu else true

func _on_save_slot_pressed(slot: int):
	game_manager.save_game()
	update_save_slots()
	_on_back_button_pressed()

func _on_load_slot_pressed(slot: int):
	game_manager.load_game(slot)
	get_tree().paused = false
	hide()
	
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
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
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
	load_button_logic(1)
func _on_load2_pressed():
	print("loaded slot 2")
	load_button_logic(2)
func _on_load3_pressed():
	print("loaded slot 3")
	load_button_logic(3)
func _on_loadreturn_pressed():
	load_menu.hide()
	pause_menu.show()

func load_button_logic(slot: int):
	game_manager.load_game(slot)
	_on_loadreturn_pressed()
	_on_resume_pressed()


func show_save_success_message() -> void:
	# Assuming you have a UI node for the save success message
	var save_success_message = get_tree().get_first_node_in_group("save_success_message")
	if save_success_message:
		save_success_message.show()

func return_to_pause_screen() -> void:
	# Hide any save-related UI and return to the pause menu
	var save_menu = get_tree().get_first_node_in_group("save_menu")
	if save_menu:
		save_menu.hide()
	var pause_menu = get_tree().get_first_node_in_group("pause_menu")
	if pause_menu:
		pause_menu.show()

func save_button_logic(slot:int):
	game_manager.save_game(slot)
	show_save_success_message()
	return_to_pause_screen()

func _on_save1_pressed():
	print("Saved slot 1")
	save_button_logic(1)
func _on_save2_pressed():
	print("Saved slot 2")
	save_button_logic(2)
func _on_save3_pressed():
	print("Saved slot 3")
	save_button_logic(3)
func _on_savereturn_pressed():
	save_menu.hide()
	pause_menu.show()

func _on_quit_pressed():
	#I want to change this later to provide the user a prompt that they can either exit to main menu or straight to desktop
	print("Quit to Main Menu pressed")
	get_tree().paused = false  # Unpause the game
	game_manager.return_to_main_menu()
