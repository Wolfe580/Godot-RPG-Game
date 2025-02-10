class_name ItemDatabase
extends Node

# Centralized storage for all item definitions
var weapon_definitions: Dictionary = {}
var armor_definitions: Dictionary = {}
var consumable_definitions: Dictionary = {}

# Method to register a new item definition
func register_weapon_definition(id: String, weapon_data: Dictionary) -> void:
	weapon_definitions[id] = {
		"name": weapon_data.get("name", "Unnamed Weapon"),
		"type": weapon_data.get("type", WeaponResource.WeaponType.UNARMED),
		"base_damage": weapon_data.get("base_damage", 0),
		"weight": weapon_data.get("weight", 1.0),
		"value": weapon_data.get("value", 0),
		"description": weapon_data.get("description", ""),
		"mesh": weapon_data.get("mesh", null),
		"max_ammo": weapon_data.get("max_ammo", 0),
		"projectile_range": weapon_data.get("projectile_range", 40)
	}

# Method to get a weapon definition
func get_weapon_definition(id: String) -> Dictionary:
	return weapon_definitions.get(id, {})
