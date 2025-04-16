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
@export_group("Speed")
@export var p_speed : float = 425
@export var P_ACCEL : int = 3000
@export var P_FRICTION : int = 20000
var p_vel_prep : Vector2 

#Dashing Variables
@export_group("Dash")
@export var p_dash_delay : float = 0.6
@export var p_max_dash : int = 1

#Weapon Variables
@export_group("Weapon")
@export var p_reload_time : float = 0.6
@export var p_full_reload_time : float = 1.0
@export var p_max_ammo : int = 18
var p_ammo : int = 0
var p_reloading : bool = false

@export var p_reload_label : Label #Delete Later

@export var p_bullet_scene : PackedScene
@export var p_burst_amount : int = 1


#Setter variables
var p_is_dashing : bool = false : #If dashing or 
	set(new_value):
		p_is_dashing = new_value
		if p_is_dashing == true:
			$PlaceholderSprite2D.self_modulate = Color("e3e65a")
			await get_tree().create_timer(0.25, false).timeout
			p_is_dashing = false
			$PlaceholderSprite2D.self_modulate = Color("ffffff")
		else:
			$PlaceholderSprite2D.self_modulate = Color("ffffff")


var p_consecutive_dash : int = 0 : #How many dashes the payer has done, resets after last dash
	set(new_value):
		p_consecutive_dash = new_value
		if p_consecutive_dash != 0:
			if p_dash_timer.is_stopped() == false:
				p_dash_timer.stop()
			p_dash_timer.start(p_dash_delay)
			
			p_is_dashing = true


@export var p_bullet_amount : int = 1 : 
	set(new_value): #Update the bullet spread basd on bullet amount
		p_bullet_amount = new_value
		@warning_ignore("integer_division")
		p_bullet_spread = ((15 * p_bullet_amount) - 15) / (p_bullet_amount * 1.5)


var p_upgrades : BaseUpgrade = null : #Apply upgrades to player
	set(new_value):
		p_upgrades = new_value
		if p_upgrades != null:
			p_upgrades.apply_player_upgrade(self)
			p_upgrades = null


#Misc Variables
var p_bullet_upgrades : Array = []
var p_can_shoot : bool = true
var p_bullet_spread : float = 0.0


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	#Variable prep
	p_can_shoot = true
	p_is_dashing = false
	p_consecutive_dash = 0
	p_reload_label.visible = false
	p_ammo = p_max_ammo
	
	p_vel_prep = Vector2.ZERO
	velocity = Vector2.ZERO
	
	$PlaceholderSprite2D.self_modulate = Color("ffffff")
	
	#Signal connecting
	p_hitbox_component.hitbox_entered.connect(player_hit_signalled)
	p_health_component.zero_health.connect(player_no_health)


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta):
	#Player movement
	var p_input = Input.get_vector("left", "right", "up", "down") #Get movement vector
	player_movement(p_input, delta)
	
	#Player roll
	if Input.is_action_just_pressed("dash"):
		player_dash(p_input)
	
	#Player shooting
	weapon_functionality()
	
	velocity = Vector2(p_vel_prep.x, p_vel_prep.y / 2) #Make velocity isometric
	var _error = move_and_slide() #Apply velocity
	
	Global.player_position = global_position
	Global.player_hp = p_health_component.health
	Global.player_max_hp = p_health_component.max_health


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
	if p_input and p_consecutive_dash <= p_max_dash:
		p_vel_prep = p_input * 2200
		p_consecutive_dash += 1
 

#---------------------------------------------------------------------------------------------------------------------------
func weapon_functionality():
	#Reloading functionality
	if (Input.is_action_just_pressed("reload") or (Input.is_action_just_pressed("primary_attack") and p_ammo <= 0)) and p_reloading == false:
		p_reload_label.visible = true
		p_reloading = true
		
		await get_tree().create_timer(p_full_reload_time, false).timeout
		
		p_reload_label.visible = false
		p_reloading = false
		p_ammo = p_max_ammo
	
	#Shooting functionality
	if Input.is_action_pressed("primary_attack") and p_can_shoot == true and p_reloading == false:
		for _n in range(0, p_burst_amount):
			if p_ammo >= 1:
				player_shoot()
				
			await get_tree().create_timer(p_reload_time / (p_burst_amount), false).timeout
	
	#Update global variables
	Global.player_ammo = p_ammo
	Global.player_max_ammo = p_max_ammo


#---------------------------------------------------------------------------------------------------------------------------
#Player Shoot Function
func player_shoot():
	Camera.apply_camera_shake(4.0)
	
	p_can_shoot = false
	p_ammo -= 1
	p_shoot_timer.stop()
	p_shoot_timer.start(p_reload_time)
	
	#The bullet instance
	for bullet in range(0, p_bullet_amount):
		var bullet_instance := p_bullet_scene.instantiate()
		var mouse_pos := get_global_mouse_position()
		var mouse_dir := mouse_pos - global_position
		mouse_dir.y *= 2
		
		#Bullet spawned
		bullet_instance.global_position = global_position
		bullet_instance.rotation = mouse_dir.angle()
		get_parent().add_child(bullet_instance)
		
		#Bullet rotation offset based on amount of bullets fired
		@warning_ignore("integer_division")
		var bullet_rotation_offset = bullet - (p_bullet_amount / 2)
		if bullet_rotation_offset % 1: 
			bullet_rotation_offset = -bullet_rotation_offset
		bullet_instance.rotation += deg_to_rad(p_bullet_spread) * bullet_rotation_offset
		
		#Apply upgrades to bullet
		for upgrades in p_bullet_upgrades:
				upgrades.apply_upgrade(bullet_instance)
		
		bullet_instance.implement_stats()
		bullet_instance.death_timer_node.start(bullet_instance.life_time)


#---------------------------------------------------------------------------------------------------------------------------
#Player damage function
func player_hit_signalled(hurtbox: HurtboxComponent):
	if p_consecutive_dash == 0:
		#Variables changed
		p_health_component.health -= hurtbox.hurt_damage
		p_vel_prep *= -hurtbox.hurt_knockback
		
		p_hitbox_component.is_hit = true
		p_hitbox_component.hit_timer.start(p_hitbox_component.hit_delay)
		
		Camera.apply_camera_shake(15.0)
		
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
	p_consecutive_dash = 0


#---------------------------------------------------------------------------------------------------------------------------
#Player shoot timeout signal
func _on_shoot_timer_timeout() -> void:
	p_can_shoot = true
