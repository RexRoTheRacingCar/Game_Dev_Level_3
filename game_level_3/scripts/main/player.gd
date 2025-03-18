############################## Player ##############################
extends CharacterBody2D
class_name Player


#p is short for "Player"
#Node variables
@export_group("Nodes")
@export var p_dash_timer : Timer
@export var p_shoot_timer : Timer
@export var p_hitbox_component : HitboxComponent
@export var p_health_component : HealthComponent

#Movement variables
@export_group("Customisable")
@export var p_speed : float = 425
@export var P_ACCEL : int = 3000
@export var P_FRICTION : int = 20000
var p_vel_prep : Vector2 

@export var p_dash_delay : float = 0.4

@export var p_reload_time : float = 0.4

@export var p_bullet_scene : PackedScene

#Misc variables
var p_dashing : bool = false
var p_attacking : bool = false
var p_bullet_upgrades : Array = []
var p_upgrades : Array = [] :
	set(new_value):
		p_upgrades.append(new_value)
		
		
		
var p_can_shoot : bool = true



#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	#Variable prep
	p_attacking = false
	p_dashing = false
	p_can_shoot = true
	
	p_vel_prep = Vector2.ZERO
	velocity = Vector2.ZERO
	
	$PlaceholderSprite2D.self_modulate = Color("ffffff")
	
	#Signal connecting
	p_hitbox_component.hitbox_entered.connect(player_hit_signalled)
	p_health_component.zero_health.connect(player_no_health)


#---------------------------------------------------------------------------------------------------------------------------
#THE PHYSICS PROCESS
#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta):
	if p_attacking == false:
		#Player movement
		var p_input = Input.get_vector("left", "right", "up", "down") #Get movement vector
		player_movement(p_input, delta)
		
		#Player roll
		if Input.is_action_just_pressed("dash"):
			player_dash(p_input)
		
		#Player shoot
		if Input.is_action_pressed("primary_attack") and p_can_shoot == true:
			player_shoot()
	
	
	velocity = Vector2(p_vel_prep.x, p_vel_prep.y / 2) #Make velocity isometric
	var _error = move_and_slide() #Apply velocity


#---------------------------------------------------------------------------------------------------------------------------
#Player Movement Function
func player_movement(p_input, delta):
	#If moving
	if p_input: 
		p_vel_prep = p_vel_prep.move_toward(p_input * p_speed , delta * P_ACCEL)
	
	#If not moving
	else: 
		p_vel_prep = p_vel_prep.move_toward(Vector2(0,0), delta * P_FRICTION)


#---------------------------------------------------------------------------------------------------------------------------
#Player Dash Function
func player_dash(p_input):
	if p_dashing == false and p_input:
		p_dashing = true
		p_vel_prep = p_input * 2200
		
		p_dash_timer.start(p_dash_delay)
		
		$PlaceholderSprite2D.self_modulate = Color("e3e65a")


#---------------------------------------------------------------------------------------------------------------------------
#Player Shoot Function
func player_shoot():
	p_can_shoot = false
	p_shoot_timer.start(p_reload_time)
	
	#The bullet instance
	var bullet_instance := p_bullet_scene.instantiate()
	var mouse_pos := get_global_mouse_position()
	var mouse_dir := mouse_pos - global_position
	mouse_dir.y *= 2
	
	#Bullet spawned
	get_parent().add_child(bullet_instance)
	bullet_instance.global_position = global_position
	bullet_instance.rotation = mouse_dir.angle()
	
	#Apply upgrades to bullet
	for upgrades in p_bullet_upgrades:
			upgrades.apply_upgrade(bullet_instance)
	
	bullet_instance.implement_stats()


#---------------------------------------------------------------------------------------------------------------------------
#Player damage function
func player_hit_signalled(hurtbox: HurtboxComponent):
	if p_dashing == false:
		#Variables changed
		p_health_component.health -= hurtbox.hurt_damage
		p_vel_prep *= -hurtbox.hurt_knockback
		
		p_hitbox_component.is_hit = true
		p_hitbox_component.hit_timer.start(p_hitbox_component.hit_delay)
		
		$PlaceholderSprite2D.self_modulate = Color("ff2121")
		await get_tree().create_timer(0.9, false).timeout
		$PlaceholderSprite2D.self_modulate = Color("ffffff")
		
	else:
		p_hitbox_component.hit_timer.start(0.1)


#---------------------------------------------------------------------------------------------------------------------------
#Player has 0 HP
func player_no_health():
	get_tree().quit()


#---------------------------------------------------------------------------------------------------------------------------
#Player dash timer signal
func _on_dash_timer_timeout():
	if p_dashing == true:
		p_dashing = false
		
		$PlaceholderSprite2D.self_modulate = Color("ffffff")


#---------------------------------------------------------------------------------------------------------------------------
#Player shoot timeout signal
func _on_shoot_timer_timeout() -> void:
	p_can_shoot = true
