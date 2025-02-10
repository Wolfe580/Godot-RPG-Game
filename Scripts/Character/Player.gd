extends GameCharacter
class_name Player

@onready var profilehud : Control = $PlayerHUD
@onready var damage_overlay = $"../Player/PlayerHUD/FirstPersonHurt"
@onready var health_bar: ProgressBar = $"../Player/PlayerHUD/HealthBar"
@onready var ammo_bar : ProgressBar = $"../Player/PlayerHUD/AmmoBar"



func ready():
	health_bar.init_health(health)
	damage_overlay.modulate = Color.TRANSPARENT
	

func showplayerHUD():
	profilehud.show()
func hideplayerHUD():
	profilehud.hide()

func hurt(damage : float):
	health -= damage
	#update health bar 
	health_bar._set_health(health)
	damage_overlay.modulate = Color.WHITE
	
	#Player death on health going below 0.
	if health <= 0:
		_die()

	#providing HUD feedback for player damage.
	if hurt_tween:
		hurt_tween.kill()
	hurt_tween = create_tween()
	hurt_tween.tween_property(damage_overlay, "modulate", Color.TRANSPARENT, 0.5)
	
#Capturing Player input
func _input(event):
	if event is InputEventMouseMotion:
		var MouseEvent = event.relative *SENSITIVITY
		CameraLook(MouseEvent)
		
#Sprint 
	if Input.is_action_pressed("movement_sprint"):
		is_sprinting = true
	else: 
		is_sprinting = false
#Player flashlight (lamp)
	if event.is_action_pressed("flashlight") and lampunlocked == true:
		print(lampstate)
		if lampstate == true:
			lamp.hide()
			lampstate = false
		else:
			lamp.show()
			lampstate = true
#Action button
	if Input.is_action_pressed("Action"):
		pass
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory_slot_1"):
		current_weapon = KIRYU
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

var player_stats : Dictionary = {
	"health": health,
	"level": level,
	"strength": strength,
	"charisma": charisma,
	"literacy": literacy,
	"endurance": endurance,
	"dexterity": dexterity,
	"perception": perception,
	"archery_bow": bow_mastery,
	"archery_crossbow": crossbow_mastery,
	"sword_mastery": sword_mastery,
	"dagger_mastery": dagger_mastery,
	"spear_mastery": spear_mastery,
	"sling_mastery": sling_mastery,
	"warhammer_mastery": warhammer_mastery,
	"unarmed_mastery": unarmed_mastery,
	"player_karma": player_karma,
	"reputation_with_Rome": reputation_with_Rome,
	"reputation_with_Votandi": reputation_with_Votandi,
	"reputation_with_Damnonii": reputation_with_Damnonii,
}
var player_traits : Dictionary= {
	"battle_hardened" : battle_hardened,
	"fists_of_fury" : fists_of_fury,
	"slinger" : slinger,
	"john_warhammer" : john_warhammer,
	"blade_expert" : blade_expert,
	"rogue" : rogue,
	"bow_expert" : bow_expert,
	"crossbow_master" : crossbow_master,
	"woodsman" : woodsman,
	"farmer" : farmer,
	"fisherman" : fisherman,
	"animal_tamer" : animal_tamer,
	"miner" : miner,
}

var player_reputation : Dictionary= {
		"player_karma": player_karma,
	"reputation_with_Rome": reputation_with_Rome,
	"reputation_with_Votandi": reputation_with_Votandi,
	"reputation_with_Damnonii": reputation_with_Damnonii,
}
var player_inventory : Dictionary= {
	
}


func get_player_data() -> Dictionary:
	return {
		"position": global_transform.origin,
		"stats": player_stats,
		"traits": player_traits,
		"reputation": player_reputation,
		"inventory": player_inventory
	}

# Update player stats from a dictionary
func update_stats_from_save(stats: Dictionary) -> void:
	health = stats.get("health", health)
	level = stats.get("level", level)
	strength = stats.get("strength", strength)
	charisma = stats.get("charisma", charisma)
	literacy = stats.get("literacy", literacy)
	endurance = stats.get("endurance", endurance)
	dexterity = stats.get("dexterity", dexterity)
	perception = stats.get("perception", perception)

# Update player traits from a dictionary
func update_traits_from_save(traits: Dictionary) -> void:
	battle_hardened = traits.get("battle_hardened", battle_hardened)
	fists_of_fury = traits.get("fists_of_fury", fists_of_fury)
	slinger = traits.get("slinger", slinger)
	john_warhammer = traits.get("john_warhammer", john_warhammer)
	blade_expert = traits.get("blade_expert", blade_expert)
	rogue = traits.get("rogue", rogue)
	bow_expert = traits.get("bow_expert", bow_expert)
	crossbow_mastery = traits.get("crossbow_mastery", crossbow_mastery)

# Update player reputation from a dictionary
func update_reputation_from_save(reputation: Dictionary) -> void:
	player_reputation = reputation.get("player_reputation", player_reputation)
	reputation_with_Rome = reputation.get("reputation_with_Rome", reputation_with_Rome)
	reputation_with_Votandi = reputation.get("reputation_with_Votandi", reputation_with_Votandi)
	reputation_with_Damnonii = reputation.get("reputation_with_Damnonii", reputation_with_Damnonii)

# Update player inventory from a dictionary
func update_inventory_from_save(inventory: Dictionary) -> void:
	ammo = inventory.get("ammo", ammo)
	# Add more inventory items here as needed

func save_game():
	var player_data = get_player_data()
	var world_data = {}  # Add world data here
	var entities_data = []  # Add entities data here
	SaveManager.save_game(player_data, world_data, entities_data)

func load_game():
	var save_data = SaveManager.load_game()
	if save_data:
		global_transform.origin = save_data["player"].get("position", Vector3())
		update_stats_from_save(save_data["player"].get("stats", {}))
		update_traits_from_save(save_data["player"].get("traits", {}))
		update_reputation_from_save(save_data["player"].get("reputation", {}))
		update_inventory_from_save(save_data["player"].get("inventory", {}))
