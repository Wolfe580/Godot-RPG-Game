extends Resource
class_name WeaponInstance


@export var weapon_resource: WeaponResource

@export var current_ammo: int
@export var condition: float = 100.0
@export var modifications: Dictionary = {}
@export var unique_id: String

func get_current_damage() -> int:
	var base_damage = weapon_resource.base_damage
	var damage_modifier = condition / 100.0

	# Apply any damage modifications
	var mod_multiplier = modifications.get("damage_multiplier", 1.0)
	return int(base_damage * damage_modifier * mod_multiplier)

# Serialization method
func to_dictionary() -> Dictionary:
	var base_dict = weapon_resource.to_dictionary()
	base_dict.merge({
		"current_ammo": current_ammo,
		"condition": condition,
		"modifications": modifications,
		"unique_id": unique_id
	})
	return base_dict
