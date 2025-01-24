extends Node

## Sounds
#Player
const DEAD = preload("res://Sound Effects/dead.mp3")
const LANDING = preload("res://Sound Effects/landing.mp3")

#Footsteps
const STONE_FLOOR_1 = preload("res://Sound Effects/Footsteps/stone_floor_1.mp3")
const STONE_FLOOR_2 = preload("res://Sound Effects/Footsteps/stone_floor_2.mp3")
const STONE_FLOOR_3 = preload("res://Sound Effects/Footsteps/stone_floor_3.mp3")

#Bow
const BOW_FIRING_1 = preload("res://Sound Effects/Weapons/Bow/bow_firing_1.mp3")
const BOW_FIRING_2 = preload("res://Sound Effects/Weapons/Bow/bow_firing_2.mp3")
const BOW_FIRING_3 = preload("res://Sound Effects/Weapons/Bow/bow_firing_3.mp3")

#Crossbow
const CROSSBOW_FIRING_1 = preload("res://Sound Effects/Weapons/Crossbow/crossbow_firing_1.mp3")

#Sling
const SLING_FIRE_1 = preload("res://Sound Effects/Weapons/Sling/sling_fire_1.mp3")

#Spear
const SPEAR_STAB_1 = preload("res://Sound Effects/Weapons/Spear/spear_stab_1.mp3")

#Sword
const SWORD_SWING_1 = preload("res://Sound Effects/Weapons/Sword/sword_swing_1.mp3")
const SWORD_SWING_2 = preload("res://Sound Effects/Weapons/Sword/sword_swing_2.mp3")

#Dagger
const DAGGER_SWING_1 = preload("res://Sound Effects/Weapons/Dagger/dagger_swing_1.mp3")
const DAGGER_SWING_2 = preload("res://Sound Effects/Weapons/Dagger/dagger_swing_2.mp3")
const DAGGER_SWING_3 = preload("res://Sound Effects/Weapons/Dagger/dagger_swing_3.mp3")

#Warhammer
const WARHAMMER_SWING_1 = preload("res://Sound Effects/Weapons/Warhammer/Warhammer_swing_1.mp3")
const WARHAMMER_SWING_2 = preload("res://Sound Effects/Weapons/Warhammer/Warhammer_swing_2.mp3")

#Unarmed
const MELEE_SWING_1 = preload("res://Sound Effects/Weapons/Unarmed/melee_swing_1.ogg")
const MELEE_SWING_2 = preload("res://Sound Effects/Weapons/Unarmed/melee_swing_2.mp3")
const MELEE_SWING_3 = preload("res://Sound Effects/Weapons/Unarmed/melee_swing_3.mp3")

#Axe
const AXE_SWING_1 = preload("res://Sound Effects/Weapons/Axe/axe_swing_1.mp3")
const AXE_SWING_2 = preload("res://Sound Effects/Weapons/Axe/axe_swing_2.mp3")

var footstep_stone : Array[AudioStream] = [
	STONE_FLOOR_1,
	STONE_FLOOR_2,
	STONE_FLOOR_3,
]

var bow_sounds : Array[AudioStream] = [
	BOW_FIRING_1,
	BOW_FIRING_2,
	BOW_FIRING_3,
]

var crossbow_sounds : Array[AudioStream] = [
	CROSSBOW_FIRING_1,
]

var sword_sounds : Array[AudioStream] = [
	SWORD_SWING_1,
	SWORD_SWING_2,
]

var dagger_sounds : Array[AudioStream] = [
	DAGGER_SWING_1,
	DAGGER_SWING_2,
	DAGGER_SWING_3,
]

var warhammer_sounds : Array[AudioStream] = [
	WARHAMMER_SWING_1,
	WARHAMMER_SWING_2,
]

var spear_sounds : Array[AudioStream] = [
	SPEAR_STAB_1,
]

var sling_sounds : Array[AudioStream] = [
	SLING_FIRE_1,
]

var unarmed_sounds : Array[AudioStream] = [
	MELEE_SWING_1,
	MELEE_SWING_2,
	MELEE_SWING_3,
]


func play_sfx(sound : AudioStream, parent, distance : int = 0, volume_gain : int = 0):
	var audioplayer : AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	audioplayer.stream = sound
	audioplayer.max_distance = distance
	audioplayer.volume_db = volume_gain
	audioplayer.process_mode = Node.PROCESS_MODE_ALWAYS
	
	#When sound is done, delete player
	audioplayer.connect("finished", audioplayer.queue_free)
	#Add player to child
	parent.add_child(audioplayer)
	
	#Play sound
	audioplayer.play()
