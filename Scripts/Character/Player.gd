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

func showplayerHUD():
	profilehud.show()
func hideplayerHUD():
	profilehud.hide()

# Get player data for saving
func get_player_data() -> Dictionary:
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
		}
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
	if event is InputEventMouseMotion:
		var MouseEvent = event.relative * SENSITIVITY
		CameraLook(MouseEvent)

	if event.is_action_pressed("flashlight") and lampunlocked:
		lamp.visible = !lamp.visible

# Physics process
func _physics_process(delta: float) -> void:
	# Handle movement, jumping, etc.
	pass

# Camera look function
func CameraLook(Movement: Vector2):
	CameraRotation += Movement
	CameraRotation.y = clamp(CameraRotation.y, -1.5, 1.2)

	transform.basis = Basis()
	camera.transform.basis = Basis()

	rotate_object_local(Vector3(0, 1, 0), -CameraRotation.x)
	camera.rotate_object_local(Vector3(1, 0, 0), -CameraRotation.y)
