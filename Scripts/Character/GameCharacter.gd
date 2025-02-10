extends CharacterBody3D
class_name GameCharacter

signal hit
const WeaponSystem = preload("res://Scripts/Game/Systems/Weapon/weaponsystem.gd")

#Character animations
#@onready var animation_player=$"../../AnimationTree/AnimationPlayer"
#@onready var Idleanim=$Idle
#@onready var Walkanim=$Walking


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
@export var characterlocation = Vector3()
var is_sprinting = false
#Character - Movement - Jump + Falling
@export_category("Player Movement - Vertical")
const JUMP_VELOCITY = 4.5
@export var gravity = 9.8
var dir = Vector3()
var vel = Vector3()
var old_vel: float = 0.0
@export var fall_damage_threshold = 6
#Character - Movement - Crouch + Crawl
var stand_height: float
var crouch_height: float
var crawl_height: float

#Player Camera
const MAX_SLOPE_ANGLE = 40
var CameraRotation = Vector2(0,0)
@onready var head = $Head
@onready var camera= $Head/Camera3D


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
@export var crossbow_master : bool = false
#traits related to gathering in the world
@export var woodsman : bool = false
@export var farmer : bool = true
@export var fisherman: bool = false
@export var animal_tamer: bool = false
@export var miner : bool = true
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
@export var bow_mastery : float = 0
@export var crossbow_mastery : float = 0
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
@export var player_karma : float = 0
@export var reputation_with_Rome : float = 0
@export var reputation_with_Votandi : float = 0
@export var reputation_with_Damnonii : float = 0
#Max reputation values
var player_karma_max : float = 100
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
@export var current_weapon : WeaponResource = UNARMED
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
const KIRYU = preload("res://Resources/Weapons/Kiryu.tres")

var ammo : Dictionary = {
	"melee": 1,
	"bow":15,
	"crossbow":20,
	"sling":200,
}

#Saving user profile (likely to be relocated to a main menu if I understand correctly)
var config = ConfigFile.new()

#Variables for pause menu
@onready var pause_menu = $"../PauseMenu"


#Functions
#Readying player state
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	lamp = $CharacterLamp
	lamp.hide()
	


#Saving player information such as stats, inventory and location - this has to be linked with player profile and will be done using persisted settings
func _save():
	pass

func CharSkillLogic():
	pass
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
	pass

#Calculating whether or not the player has obtained certain traits related to their learned skills
func calc_player_traits():
	pass

func update_stats():
	bow_mastery = Utils.clamp_value(bow_mastery, archery_bow_min, archery_bow_max)
	crossbow_mastery = Utils.clamp_value(crossbow_mastery, archery_crossbow_min, archery_crossbow_max)
	sword_mastery = Utils.clamp_value(sword_mastery, sword_mastery_min, sword_mastery_max)
	dagger_mastery = Utils.clamp_value(dagger_mastery, dagger_mastery_min, dagger_mastery_max)
	spear_mastery = Utils.clamp_value(spear_mastery, spear_mastery_min, spear_mastery_max)
	sling_mastery = Utils.clamp_value(sling_mastery, sling_mastery_min, sling_mastery_max)
	warhammer_mastery = Utils.clamp_value(warhammer_mastery, warhammer_mastery_min, warhammer_mastery_max)
	unarmed_mastery = Utils.clamp_value(unarmed_mastery, unarmed_mastery_min, unarmed_mastery_max)
	
func increase_bow_mastery(amount: float):
	bow_mastery += amount
	update_stats()

func increase_crossbow_mastery(amount: float):
	crossbow_mastery += amount
	update_stats()
	
func increase_sword_mastery(amount: float):
	sword_mastery += amount
	update_stats()

func increase_dagger_mastery(amount: float):
	dagger_mastery += amount
	update_stats()

func increase_spear_mastery(amount: float):
	spear_mastery += amount
	update_stats()

func increase_sling_mastery(amount: float):
	sling_mastery += amount
	update_stats()

func increase_warhammer_mastery(amount: float):
	warhammer_mastery += amount
	update_stats()

func increase_unarmed_mastery(amount: float):
	unarmed_mastery += amount
	update_stats()

##Animations
#func handle_animations(direction:Vector3):
#	if direction != Vector3.ZERO:
#		#Character walking animation
#		if not animation_player.current_animation == "walk":
#			Idleanim.hide()
#			Walkanim.show()
#			animation_player.play("walk")
#	else: 
#		#idle animation
#		if not animation_player.current_animation == "idle":
#			Walkanim.show()
#			Idleanim.show()
#			animation_player.play("idle")
