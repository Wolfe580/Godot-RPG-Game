extends ProgressBar

#Link timer and damage bar to display health loss. There is two bars ontop of each other, one which shows current health and the other which represents the damage the player has taken. 
@onready var timer = $Timer
@onready var damage_bar = $DamageBar

#Establishing health with a setter
var health = 0 : set = _set_health

#Functions
#Setting the player's health bar to be equal to current health.
func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	if health <= 0:
		queue_free()
	#if the player has lost health then start the timer that provides lag in updating the health bar - visual representation of declining health. 
	if health < prev_health:
		timer.start()
		_on_timer_timeout()
	else:
		damage_bar.value = health
	
#Initialising health bar and relevant values
func init_health(_health):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health
#Setting player health visual to catch up
func _on_timer_timeout() -> void:
	damage_bar.value = health
