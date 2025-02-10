extends Resource
class_name WeaponResource

#Creating weapon variable types
enum WeaponType {
	SWORD,
	AXE,
	DAGGER,
	BOW,
	CROSSBOW,
	SLING,
	SPEAR,
	WARHAMMER,
	UNARMED,
	KIRYU
}

#Setting variables for weapons
@export var weaponID : int
@export var weaponName : String
@export var weaponType : WeaponType
@export var ammo: String
@export var mesh: ArrayMesh
@export var firerate: float
@export var cooldown : float = 0.2 #time in seconds
@export var sway : float = 0.15
@export var ismelee: bool = false
@export var automatic : bool = false
@export var onehanded : bool = true
@export var weight : float
@export var value : float
@export var weapon_mesh: Mesh
@export var icon: Texture2D

#Setting up Weapon sound systems - no audio yet implemented
@export_category("Sounds")
@export var attack_sounds: Array[AudioStream]
@export var reload_sound : AudioStream
@export var dry_fire_sound: AudioStream = preload("res://Sound Effects/Weapons/Unarmed/melee_swing_1.ogg")

#Establishing projectile stats
@export_category("Projectile stats")
@export var damage: int
@export var spread: float 
@export var max_ammo: int
@export var projectile_amount : int = 1
@export var projectile_range: int = 40

func to_dictionary() -> Dictionary:
	return{
	"weapon_id": weaponID,
	"weapon_name": weaponName,
	"weapon_type": weaponType,
	"base_damage": damage,
	"max_ammo": max_ammo,
	"reload_time": cooldown,
	"fire_rate": firerate,
	"range": projectile_range,
	"weight": weight,
	"value": value
	}
