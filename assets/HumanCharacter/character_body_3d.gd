extends CharacterBody3D
class_name Player
const WeaponSystem = preload("res://Systems/weapon_system.gd")

#System Nodes
@onready var weapon: Node = $WeaponSystem

#Character Type
@export_category("Character Type")
@export var ishuman : bool = true
@export var isfriend : bool = false
@export var isenemy: bool = false


#Character - Movement
@export_category("Player Movement - Horizontal")
@export var SPEED = 5.0
@export var SENSITIVITY = 0.01
@export var MAX_SPEED = 20
@export var MAX_SPRINT_SPEED = 30
@export var ACCEL= 4.5
@export var DEACCEL = 16
@export var SPRINT_ACCEL = 18
var is_sprinting = false

#Character Jump + Falling
@export_category("Player Movement - Vertical")
const JUMP_VELOCITY = 4.5
@export var gravity = 9.8
var dir = Vector3()
var vel = Vector3()
var old_vel: float = 0.0
var stand_height: float
@export var fall_damage_threshold = 6

#Player Camera
const MAX_SLOPE_ANGLE = 40
var CameraRotation = Vector2(0,0)
@onready var head = $Head
@onready var camera= $Head/Camera3D
@onready var damage_overlay = $FirstPersonHurt

#Flashlight
var lamp
var lampstate = false
var lampunlocked = true

#Player Health 
@export_category("Player Health")
@export var health : int = 100
@export var max_health: int = 100
var isalive: bool = true
var isdead: bool = false
@onready var health_bar: ProgressBar = $HealthBar

#Player Stats - Personal
@export_category("Player Stats - Personal")
@export var level : float = 0 
@export var strength : float = 0
@export var charisma : float = 0
@export var literacy: float = 0
@export var endurance: float = 0
@export var dexterity: float = 0
@export var perception: float = 0
var max_level: float = 100
var max_strength : float = 10
var max_charisma : float = 10
var max_literacy: float = 10
var max_endurance: float = 10
var max_dexterity: float = 10
var max_perception: float = 10

#Player Stats - Traits
@export_category("Player Stats - Traits")
#traits related to weapon mastery
@export var battle_hardened : bool = false
@export var fists_of_fury : bool = false
@export var slinger : bool = false
@export var john_warhammer : bool = false
@export var blade_expert : bool = false
@export var rogue : bool = false
@export var bow_expert : bool = false
@export var crossbow_mastery : bool = false
#traits related to gathering in the world
@export var woodsman : bool = false

#traits related to refining materials

#traits related to reputation
@export var bandit : bool = false
@export var hero : bool = false
@export var Friend_of_Rome : bool = false
@export var Friend_of_Votandi : bool = false
@export var Friend_of_Damnonii : bool = false

#Player Stats - Learned
@export_category("Player Stats - Learned")
#Learned stats related to weapons.
@export var archery_bow : float = 0
@export var archery_crossbow : float = 0
@export var sword_mastery : float = 0
@export var dagger_mastery : float = 0
@export var spear_mastery : float = 0
@export var sling_mastery : float = 0
@export var warhammer_mastery : float = 0
@export var unarmed_mastery : float = 0
#Max value of stats
var archery_bow_max : float = 100
var archery_crossbow_max : float = 100
var sword_mastery_max : float = 100
var dagger_mastery_max : float = 100
var spear_mastery_max : float = 100
var sling_mastery_max : float = 100
var warhammer_mastery_max : float = 100
var unarmed_mastery_max : float = 100
#Min value of stats
var archery_bow_min : float = -100
var archery_crossbow_min : float = -100
var sword_mastery_min : float = -100
var dagger_mastery_min : float = -100
var spear_mastery_min : float = -100
var sling_mastery_min : float = -100
var warhammer_mastery_min : float = -100
var unarmed_mastery_min : float = -100

#Player Reputation
@export_category("Player Reputation")
@export var player_reputation : float = 0
@export var reputation_with_Rome : float = 0
@export var reputation_with_Votandi : float = 0
@export var reputation_with_Damnonii : float = 0
#Max reputation values
var player_reputation_max : float = 100
var reputation_with_Rome_max : float = 100
var reputation_with_Votandi_max : float = 100
var reputation_with_Damnonii_max : float = 100
#Min reputation values
var player_reputation_min : float = -100
var reputation_with_Rome_min : float = -100
var reputation_with_Votandi_min : float = -100
var reputation_with_Damnonii_min : float = -100

#Player inventory
@export_category("Player Inventory")


#Player Weapons
@export_category("Player Weapon")
@onready var projectile_raycast: RayCast3D = $Head/Hand/Projectile_RayCast3D
@export var current_weapon : Weapon = UNARMED
var can_attack: bool = true
var is_reloading: bool= false
var current_ammo: int = current_weapon.max_ammo
var hurt_tween : Tween

const BOW = preload("res://Resources/Weapons/Bow.tres")
const CROSSBOW = preload("res://Resources/Weapons/Crossbow.tres")
const DAGGER = preload("res://Resources/Weapons/Dagger.tres")
const SLING = preload("res://Resources/Weapons/Sling.tres")
const SPEAR = preload("res://Resources/Weapons/Spear.tres")
const SWORD = preload("res://Resources/Weapons/Sword.tres")
const WARHAMMER = preload("res://Resources/Weapons/Warhammer.tres")
const UNARMED = preload("res://Resources/Weapons/Unarmed.tres")

var ammo : Dictionary = {
	"melee": 1,
	"bow":15,
	"crossbow":20,
	"sling":200,
}

#Variables for saving user data




#Functions
#Readying player state
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	lamp = $CharacterLamp
	lamp.hide()
	damage_overlay.modulate = Color.TRANSPARENT
	health_bar.init_health(health)
#Capturing Player input
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
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
 #For player death - will be constructed to provide the player the player a new screen to load from a recent save or return to the main menu
func _die():
	isalive=false
	
#Dealing with Camera rotation with mouse movement.
func CameraLook(Movement: Vector2):
		CameraRotation += Movement
		CameraRotation.y = clamp(CameraRotation.y,-1.5,1.2)
		
		
		transform.basis= Basis()
		camera.transform.basis= Basis()
		
		rotate_object_local(Vector3(0, 1, 0), -CameraRotation.x) #first rotate y
		camera.rotate_object_local(Vector3(1, 0, 0), -CameraRotation.y) #then rotate x 


#Player movement and jumping
func _physics_process(delta: float) -> void:
	#Gun Logic - may be better to move this elsewhere?
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
	
	#fall damage
	if old_vel < 0:
		var veldiff = velocity.y - old_vel
		if veldiff > fall_damage_threshold:
			hurt(veldiff - fall_damage_threshold)
	old_vel=velocity.y
	
	#sprinting
	if is_sprinting:
		velocity.x *= MAX_SPRINT_SPEED
	else:
		velocity.x *= MAX_SPEED
	
#Dealing with player damage
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
	
	
	
#Player fire
