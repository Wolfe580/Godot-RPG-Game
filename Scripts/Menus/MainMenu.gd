# MainMenu.gd
extends Control

@onready var game_manager = $"../GameManager"
@onready var save_manager = $"/root/SaveManager"

# Menu layouts
@onready var MainMenuLayout = $MainMenuLayout
@onready var MainMenuLoad = $MainMenuLoad
@onready var MainMenuSettings = $MainMenuSettings
#@onready var character_creation_menu: Control = $CharacterCreation

# Main menu buttons
@onready var NewGameButton = $MainMenuLayout/NewGameButton
@onready var LoadGameButton = $MainMenuLayout/LoadGameButton
@onready var SettingsButton = $MainMenuLayout/SettingsButton
@onready var ExitButton = $MainMenuLayout/ExitButton

# Load game buttons and labels
@onready var LoadSlot1 = $MainMenuLoad/LoadSlot1Button
@onready var LoadSlot2 = $MainMenuLoad/LoadSlot2Button
@onready var LoadSlot3 = $MainMenuLoad/LoadSlot3Button
@onready var LoadReturn = $MainMenuLoad/Return
@onready var slot1_info = $MainMenuLoad/Slot1Info
@onready var slot2_info = $MainMenuLoad/Slot2Info
@onready var slot3_info = $MainMenuLoad/Slot3Info


# In your MainMenu.gd
@onready var new_game_manager = $NewGameManager
@onready var character_creation_menu = $CharacterCreation  # Add this UI if you want character customization


func _ready() -> void:
	setup_menu_visibility()
	connect_buttons()
	#update_save_slots()

func setup_menu_visibility():
	MainMenuLayout.show()
	MainMenuLoad.hide()
	MainMenuSettings.hide()

func start_new_game(slot: int) -> void:
	if save_manager.save_exists(slot):
		show_overwrite_confirmation(slot)
	else:
		_create_new_game(slot)

func start_newload_game(slot: int) -> void:
	if save_manager.save_exists(slot):
		show_load_confirmation(slot)
	else:
		var dialog = ConfirmationDialog.new()
		dialog.dialog_text = "No save file exists in this slot - please choose a valid save!" % slot
		dialog.confirmed.connect(func(): _create_new_game(slot))

func show_load_confirmation(slot: int) -> void:
	var dialog = ConfirmationDialog.new()
	dialog.dialog_text = "Confirm loading from slot %d?" % slot
	dialog.confirmed.connect(func(): load_game(slot))
	add_child(dialog)
	dialog.popup_centered()
	
func show_overwrite_confirmation(slot: int) -> void:
	var dialog = ConfirmationDialog.new()
	dialog.dialog_text = "Save slot %d already exists. Overwrite?" % slot
	dialog.confirmed.connect(func(): _create_new_game(slot))
	add_child(dialog)
	dialog.popup_centered()

func _create_new_game(slot: int) -> void:
	var character_customization = {}
	if character_creation_menu and character_creation_menu.visible:
		character_customization = character_creation_menu.get_customization_data()
	
	game_manager.create_and_start_new_game(slot, character_customization)
	hide()

func connect_buttons():
	# Connect all button signals
	NewGameButton.connect("pressed", self._on_new_game_pressed)
	LoadGameButton.connect("pressed", self._on_load_game_pressed)
	SettingsButton.connect("pressed", self._on_settings_pressed)
	ExitButton.connect("pressed", self._on_exit_pressed)
	
	LoadSlot1.connect("pressed", self._on_loadslot1_pressed)
	LoadSlot2.connect("pressed", self._on_loadslot2_pressed)
	LoadSlot3.connect("pressed", self._on_loadslot3_pressed)
	LoadReturn.connect("pressed", self._on_loadslotreturn_pressed)
	

func update_save_slots():
	for slot in range(1, 4):
		var metadata = save_manager.get_save_metadata(slot)
		print("USS metadata:")
		print(metadata)
		var slot_button = get_node("MainMenuLoad/LoadSlot%dButton" % slot)
		
		if metadata != null and metadata.size() > 0:
			var timestamp = metadata.get("timestamp", 0)
			var datetime = Time.get_datetime_dict_from_unix_time(timestamp)
			var date_string = "%d/%d/%d %02d:%02d" % [
				datetime.month, datetime.day, datetime.year,
				datetime.hour, datetime.minute
			]
			
			var custom_metadata = metadata.get("custom_metadata", {})
			var level = custom_metadata.get("level", 1)
			var location = custom_metadata.get("location", "Unknown")
			
			slot_button.text = "Level %d - %s\n%s" % [level, location, date_string]
			slot_button.disabled = false
		else:
			slot_button.text = "Empty Save Slot"
			slot_button.disabled = true


func _on_loadslot1_pressed():
	load_game(1)

func _on_loadslot2_pressed():
	load_game(2)

func _on_loadslot3_pressed():
	load_game(3)


func load_game(slot: int):
	game_manager.load_game(slot)


# Menu navigation functions
func _on_new_game_pressed():
	MainMenuLayout.hide()
	start_new_game(0) # replace with character creation 

func _on_load_game_pressed():
	MainMenuLayout.hide()
	MainMenuLoad.show()
	update_save_slots()  # Update slot information

func _on_settings_pressed():
	MainMenuLayout.hide()
	MainMenuSettings.show()

func _on_exit_pressed():
	get_tree().quit()

func _on_loadslotreturn_pressed():
	MainMenuLoad.hide()
	MainMenuLayout.show()

func _on_NGslotreturn_pressed():
	MainMenuLayout.show()
