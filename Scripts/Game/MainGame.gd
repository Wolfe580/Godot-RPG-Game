extends Node3D

var profile_data: Dictionary
@onready var Player = $Player

##Functions
#Initialising game state
func _ready():
	# Initialize the game with the loaded profile data from main menu (or created profile!)
	print("Game started with profile data: ", profile_data)
	
	# Section to set player stats from profile data (WIP)
	Player.health = profile_data.get("health", 100)
	Player.position = profile_data.get("position", Vector3(0, 0, 0))
	
	# Load inventory (WIP)
	var inventory = profile_data.get("inventory", {})
	for item in inventory:
		Player.add_item(item, inventory[item])

#Saving player data
func save_game(profile_name:String):
	var config = ConfigFile.new()
	
	#Save current player data
	config.set_value(profile_name, "player_name", Player.player_name)
	config.set_value(profile_name, "health", Player.health)
	config.set_value(profile_name, "level", Player.level)
	config.set_value(profile_name, "position", Player.position)
	config.set_value(profile_name, "inventory", Player.inventory)
	
	#Save profile to config file
	var error = config.save("user://" + profile_name + ".cfg")
	if error == OK:
		print ("Game saved: ", profile_name)
	else: 
		print("Failed to save game: ", profile_name)
