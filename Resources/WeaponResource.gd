extends Resource
class_name Weapon
#Creating weapon variable types
enum WeaponType {
	SWORD,
	AXE,
	DAGGER,
	BOW,
	CROSSBOW,
	SLING,
	SPEAR,
	WARHAMMER
}
#Setting variables for weapons
@export var type : WeaponType
@export var ammo: String
@export var mesh: ArrayMesh
@export var cooldown : float = 0.2 #time in seconds
@export var sway : float = 0.15
@export var automatic : bool = false
@export var onehanded : bool = true
#Setting up Weapon sound systems - no audio yet implemented
@export_category("Sounds")
@export var attack_sounds: Array[AudioStream]
@export var reload_sound : AudioStream
@export var dry_fire_sound: AudioStream

#Establishing projectile stats
@export_category("Projectile stats")
@export var damage: int
@export var spread: float 
@export var max_ammo: int
@export var projectile_amount : int = 1
@export var projectile_range: int = 40
