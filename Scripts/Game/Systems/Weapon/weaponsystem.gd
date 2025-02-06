extends Node

@export var parent : CharacterBody3D
@onready var cooldown_timer: Timer = $CooldownTimer
var current_weapon : Weapon

func shoot():
	current_weapon = parent.current_weapon
	
	if parent.can_attack == true and parent.current_ammo>0:
		var valid_projectiles : Array[Dictionary]=get_projectile_raycasts()
		
		if current_weapon.ismelee == true:
			parent.current_ammo -=1
			
		#Weapon Cooldown
		parent.can_attack = false
		cooldown_timer.start(current_weapon.cooldown)
		
		#Sound Effect
		SoundManager.play_sfx(current_weapon.attack_sounds.pick_random(), parent)
		
		#Player only - WIP
		#if parent.name == "Player":
			#parent.player_arms.play_weapon_anim("recoil",2) #Need to create player arms and create recoil animation 
			#Global.update_hud.emit() #Create later
		
		#Actions for when projectiles hit
		if valid_projectiles.is_empty() == false:
			for b in valid_projectiles:
				#Check for enemy, if they are then damage them
				if b.hit_target.is_in_group("Enemy"):
					b.hit.target.change_health(current_weapon.damage * -1) #Amend to reduce enemy health later
					
					#Spawn decal
					var projectile = Global.PROJECTILE_DECAL.instantiate()
					b.hit_target.add_child(projectile)
					projectile.global_transform.origin = b.collision_point
					
					#Match decal direction to surface
					if b.collision_normal == Vector3(0,1,0):
						projectile.look_at(b.collision_point * b.collision_normal, Vector3.RIGHT)
					elif b.collision_normal == Vector3(0,-1,0):
						projectile.look_at(b.collision_point * b.collision_normal, Vector3.RIGHT)
					else:
						projectile.look_at(b.collision_point * b.collision_normal, Vector3.DOWN)
					
					#Add to decal counting array
					GameSettings.spawned_decals.append(projectile)
					
					#Check for Decal Amount
					if GameSettings.spawned_decals.size() > GameSettings.max_decals:
						GameSettings.spawned_decals[0].queue_free() #Remove oldest decal from the world
						GameSettings.spawned_decals.remove_at(0) #Remove freed decal from the list
					
					
					
					
					


func get_projectile_raycasts():
	current_weapon = parent.current_weapon
	
	var projectile_raycast = parent.projectile_raycast
	var valid_projectiles : Array[Dictionary]
	
	for b in current_weapon.projectile_amount:
		#Code example for projectile spread - not valid for current weapon set
		#var spread_x = : float = randf_range(current_weapon.spread * -1, current_weapon.spread)
		#Set spread with projectile_raycast.target_position = Vector3(spread_x,spread_y, current_weapon.projectile_range)
		
		#Collision data
		projectile_raycast.force_raycast_update()
		var hit_target = projectile_raycast.get_collider()
		var collision_point = projectile_raycast.get_collision_point()
		var collision_normal = projectile_raycast.get_collision_normal()
		
		#Obtaining object data if the bullet hit an object
		if hit_target != null:
			var valid_projectile : Dictionary = {
				"hit_target": hit_target,
				"collision_point":collision_point,
				"collision_normal":collision_normal,
			}
			
			#Add bullet data to array
			valid_projectiles.append(valid_projectile)
		
	return valid_projectiles

		
		
		
		
		
		
		
		
		
		
		
		
		
		

func _on_cooldown_timer_timeout() -> void:
	parent.can_attack = true
