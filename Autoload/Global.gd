extends Node

#Global Control
#References
var PlayerRef: CharacterBody3D
var WorldRef: Node3D

const PROJECTILE_DECAL = preload("res://scene/Game/Projectile/projectile_decal.tscn")

#UI control
#References
var PauseRef: Control

signal update_hud

##UI
#func check_menus():
#	if PauseRef.is_open == true:
#		return true
#	else:
#		return false
