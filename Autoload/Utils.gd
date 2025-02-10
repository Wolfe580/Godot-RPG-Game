extends Node


static func clamp_value(value: float, min_value: float, max_value: float) -> float:
	return clamp(value, min_value, max_value)


static func is_in_range(value: float, min_value: float, max_value: float) -> bool:
	return value >= min_value && value <= max_value

static func lerp_value(a: float, b: float, t: float) -> float:
	return a + (b - a) * t

# Calculates a path between two points using the navigation system
#static func calculate_path(start: Vector3, end: Vector3) -> Array:
#	var navigation = get_tree().root.get_node("NavigationRegion3D")  # Adjust path as needed
#	return navigation.get_simple_path(start, end)

# Checks if a target is within the field of view of an AI agent
static func is_in_field_of_view(agent: Node3D, target: Node3D, fov_angle: float) -> bool:
	var direction_to_target = (target.global_transform.origin - agent.global_transform.origin).normalized()
	var angle = rad_to_deg(agent.global_transform.basis.z.angle_to(direction_to_target))
	return abs(angle) <= fov_angle / 2

# Saves a dictionary to a JSON file
static func save_to_json(data: Dictionary, file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
		return true
	return false

# Loads a dictionary from a JSON file
static func load_from_json(file_path: String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json = JSON.new()
	
	if file:
		var data = json.get_data()
		file.close()
		return data
	return {}

# Checks if a file exists
static func file_exists(file_path: String) -> bool:
	return FileAccess.file_exists(file_path)
