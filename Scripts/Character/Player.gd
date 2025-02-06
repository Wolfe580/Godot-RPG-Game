extends GameCharacter
class_name Player

@onready var profilehud : Control = $PlayerHUD
@onready var damage_overlay = $"../Player/PlayerHUD/FirstPersonHurt"
@onready var health_bar: ProgressBar = $"../Player/PlayerHUD/HealthBar"
@onready var ammo_bar : ProgressBar = $"../Player/PlayerHUD/AmmoBar"



func ready():
	damage_overlay.modulate = Color.TRANSPARENT
	health_bar.init_health(health)

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
