extends GameCharacter
class_name Player

# Player-specific nodes
@onready var profilehud : Control = $PlayerHUD
@onready var damage_overlay = $"../Player/PlayerHUD/FirstPersonHurt"
@onready var health_bar: ProgressBar = $"../Player/PlayerHUD/HealthBar"
@onready var ammo_bar : ProgressBar = $"../Player/PlayerHUD/AmmoBar"
@onready var stamina :float = 100.0
@onready var max_stamina :float= 100.0
@onready var experience:float = 0
@onready var experience_to_next_level:float = 100.0
@onready var inventory:Dictionary={}

# Getter/setter methods
func set_health(value: float) -> void:
	health = value

func set_max_health(value: float) -> void:
	max_health = value

func set_stamina(value: float) -> void:
	stamina = value

func set_max_stamina(value: float) -> void:
	max_stamina = value

func set_level(value: int) -> void:
	level = value

func set_experience(value: float) -> void:
	experience = value

func set_experience_to_next_level(value: float) -> void:
	experience_to_next_level = value
	
func base_player_properties():
	health = 100.0
	level = 1
	experience = 0.0
	experience_to_next_level = 100.0
	inventory = {}

func add_item(item_id: String, amount: int) -> void:
	if inventory.has(item_id):
		inventory[item_id] += amount
	else:
		inventory[item_id] = amount

# Ready function
func _ready():
	health_bar.init_health(health)
	damage_overlay.modulate = Color.TRANSPARENT
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player")

func showplayerHUD():
	profilehud.show()
func hideplayerHUD():
	profilehud.hide()

# Get player data for saving
func get_save_state() -> Dictionary:
	return {
		"stats": {
			"health": health,
			"max_health": max_health,
			"level": level,
			"strength": strength,
			"charisma": charisma,
			"literacy": literacy,
			"endurance": endurance,
			"dexterity": dexterity,
			"perception": perception
		},
		"traits": {
			"battle_hardened": battle_hardened,
			"fists_of_fury": fists_of_fury,
			"slinger": slinger,
			"john_warhammer": john_warhammer,
			"blade_expert": blade_expert,
			"rogue": rogue,
			"bow_expert": bow_expert,
			"crossbow_master": crossbow_master
		},
		"reputation": {
			"player_karma": player_karma,
			"reputation_with_Rome": reputation_with_Rome,
			"reputation_with_Votandi": reputation_with_Votandi,
			"reputation_with_Damnonii": reputation_with_Damnonii
		},
		"inventory": {
			"ammo": ammo
		},
		 "position": {
			"x": global_position.x,
			"y": global_position.y,
			"z": global_position.z}
			}
func get_current_difficulty() -> int:
	var difficulty_manager = get_tree().get_first_node_in_group("difficulty_manager")
	return difficulty_manager.current_difficulty if difficulty_manager else 1

func get_game_time() -> float:
	var time_manager = get_tree().get_first_node_in_group("time_manager")
	return time_manager.elapsed_time if time_manager and time_manager.has_method("get_elapsed_time") else 0.0

func get_current_location() -> String:
	var area_manager = get_tree().get_first_node_in_group("area_manager")
	if not area_manager or not area_manager.has_method("get_current_area_name"):
		return "unknown_location"
	var location = area_manager.get_current_area_name()
	return location if location else "unknown_location"

func get_save_properties() -> Dictionary:
	return {
		"health": health,
		"max_health": max_health,
		"level": level,
		"strength": strength,
		"charisma": charisma,
		"literacy": literacy,
		"endurance": endurance,
		"dexterity": dexterity,
		"perception": perception,
		"battle_hardened": battle_hardened,
		"fists_of_fury": fists_of_fury,
		"slinger": slinger,
		"john_warhammer": john_warhammer,
		"blade_expert": blade_expert,
		"rogue": rogue,
		"bow_expert": bow_expert,
		"crossbow_master": crossbow_master,
		"player_karma": player_karma,
		"reputation_with_Rome": reputation_with_Rome,
		"reputation_with_Votandi": reputation_with_Votandi,
		"reputation_with_Damnonii": reputation_with_Damnonii,
		"ammo": ammo,
		"player_name": "Wolfe"
	}

# Load player data from a save
func load_player_data(data: Dictionary):
	if data.has("stats"):
		var stats = data["stats"]
		health = stats.get("health", health)
		max_health = stats.get("max_health", max_health)
		level = stats.get("level", level)
		strength = stats.get("strength", strength)
		charisma = stats.get("charisma", charisma)
		literacy = stats.get("literacy", literacy)
		endurance = stats.get("endurance", endurance)
		dexterity = stats.get("dexterity", dexterity)
		perception = stats.get("perception", perception)

	if data.has("traits"):
		var traits = data["traits"]
		battle_hardened = traits.get("battle_hardened", battle_hardened)
		fists_of_fury = traits.get("fists_of_fury", fists_of_fury)
		slinger = traits.get("slinger", slinger)
		john_warhammer = traits.get("john_warhammer", john_warhammer)
		blade_expert = traits.get("blade_expert", blade_expert)
		rogue = traits.get("rogue", rogue)
		bow_expert = traits.get("bow_expert", bow_expert)
		crossbow_master = traits.get("crossbow_master", crossbow_master)

	if data.has("reputation"):
		var reputation = data["reputation"]
		player_karma = reputation.get("player_karma", player_karma)
		reputation_with_Rome = reputation.get("reputation_with_Rome", reputation_with_Rome)
		reputation_with_Votandi = reputation.get("reputation_with_Votandi", reputation_with_Votandi)
		reputation_with_Damnonii = reputation.get("reputation_with_Damnonii", reputation_with_Damnonii)

	if data.has("inventory"):
		var inventory = data["inventory"]
		ammo = inventory.get("ammo", ammo)

# Player hurt function
func hurt(damage: float):
	health -= damage
	health_bar._set_health(health)
	damage_overlay.modulate = Color.WHITE

	if health <= 0:
		_die()

	if hurt_tween:
		hurt_tween.kill()
	hurt_tween = create_tween()
	hurt_tween.tween_property(damage_overlay, "modulate", Color.TRANSPARENT, 0.5)

# Player death function
func _die():
	isalive = false
	# Add logic for player death (e.g., show death screen, respawn, etc.)

# Input handling
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseMotion:
		var MouseEvent = event.relative * SENSITIVITY
		CameraLook(MouseEvent)
#Sprint 
	if Input.is_action_pressed("movement_sprint"):
		is_sprinting = true
	else: 
		is_sprinting = false
#Player flashlight (lamp)
	if event.is_action_pressed("flashlight") and lampunlocked:
		lamp.visible = !lamp.visible
#Action button
	if Input.is_action_pressed("Action"):
		pass

# In your player script
func apply_save_state(state: Dictionary, slot: int) -> void:
	print("Applying state to player: ", state)
	if state.has("position"):
		print("Found position in state: ", state.position)
		if state.position is Vector3:
			print("Set position directly: ", global_position)
		elif state.position is Dictionary and state.position.has_all(["x", "y", "z"]):
				global_position = Vector3(
				state.position.x,
				state.position.y,
				state.position.z
			)
		print("Set position from dictionary: ", global_position)
	for property in state:
		if property != "position":
			set(property, state[property])

# Physics process
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory_slot_1"):
		current_weapon = UNARMED
	if Input.is_action_just_pressed("inventory_slot_2"):
		current_weapon = SWORD
	if Input.is_action_just_pressed("inventory_slot_3"):
		current_weapon = CROSSBOW
	if Input.is_action_just_pressed("inventory_slot_4"):
		current_weapon = DAGGER
	#Semi-Automatic
	if Input.is_action_just_pressed("Attack") and current_weapon.automatic == false: #Add in menu check here once menus have been established.
		print(current_weapon)
		weapon.shoot()
	#Automatic - unlikely to be used outside of melee's unless I add in something like repeater crossbow?
	if Input.is_action_just_pressed("Attack") and current_weapon.automatic == true:
		print(current_weapon)
		weapon.shoot()
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Getting user input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	
	move_and_slide()
	
	
	#sprinting
	if is_sprinting:
		velocity.x *= MAX_SPRINT_SPEED
	else:
		velocity.x *= MAX_SPEED
	
		#fall damage
	if old_vel < 0:
		var veldiff = velocity.y - old_vel
		if veldiff > fall_damage_threshold:
			hurt(veldiff - fall_damage_threshold)
	old_vel=velocity.y

# Camera look function
func CameraLook(Movement: Vector2):
	CameraRotation += Movement
	CameraRotation.y = clamp(CameraRotation.y, -1.5, 1.2)

	transform.basis = Basis()
	camera.transform.basis = Basis()

	rotate_object_local(Vector3(0, 1, 0), -CameraRotation.x)
	camera.rotate_object_local(Vector3(1, 0, 0), -CameraRotation.y)
