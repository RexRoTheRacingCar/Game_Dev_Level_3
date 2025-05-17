############################## Player ##############################
extends CharacterBody2D
class_name Player


#p is short for "Player"
#Node variables
@export_group("Nodes")
@export var p_weapon_controller : WeaponController
@export var p_secondary_controller : SecondaryController
@export var p_dash_timer : Timer
@export var p_hitbox_component : HitboxComponent
@export var p_health_component : HealthComponent

#Movement variables
@export_group("Speed")
@export var p_speed : float = 425
@export var P_ACCEL : int = 3000
@export var P_FRICTION : int = 20000
var p_vel_prep : Vector2 


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


var p_upgrades : BaseUpgrade = null : #Apply upgrades to player
	set(new_value):
		p_upgrades = new_value
		if p_upgrades != null:
			p_upgrades.apply_player_upgrade(self)
			p_upgrades = null


#Misc Variables
@export_group("Misc")
@export var p_dash_delay : float = 0.6
@export var p_max_dash : int = 1
@export var p_damage_resistance : float = 1.0

var p_secondary_active : bool = false
var p_knockback_taken : Vector2 = Vector2.ZERO


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	set_physics_process(false)
	
	#Variable prep
	p_is_dashing = false
	p_consecutive_dash = 0
	
	p_upgrades = null
	
	p_vel_prep = Vector2.ZERO
	p_knockback_taken = Vector2.ZERO
	velocity = Vector2.ZERO
	
	$PlaceholderSprite2D.self_modulate = Color("ffffff")
	
	#Signal connecting
	p_hitbox_component.hitbox_entered.connect(player_hit_signalled)
	p_health_component.zero_health.connect(player_no_health)
	
	await get_tree().create_timer(0.09, false).timeout 
	
	call_deferred("set_physics_process", true)


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta):
	#Player movement
	var p_input = Input.get_vector("left", "right", "up", "down") #Get movement vector
	player_movement(p_input, delta)
	
	#Player roll
	if Input.is_action_just_pressed("dash"):
		player_dash(p_input)
	
	#Player shooting
	p_weapon_controller.weapon_controls(p_secondary_active)
	secondary_manage(delta)
	
	#Velocity manage
	velocity = p_vel_prep 
	velocity += p_knockback_taken
	velocity.y /= 2 #Make velocity isometric
	var _error = move_and_slide()
	
	p_knockback_taken = lerp(p_knockback_taken, Vector2.ZERO, 0.075)
	
	Global.player_position = global_position
	Global.player_velocity = velocity
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
	
	if p_secondary_active == true:
		p_vel_prep *= 0.75


#---------------------------------------------------------------------------------------------------------------------------
#Player Dash Function
func player_dash(p_input):
	if p_input and p_consecutive_dash <= p_max_dash and p_secondary_active == false:
		p_vel_prep = p_input * 2200
		p_consecutive_dash += 1


#---------------------------------------------------------------------------------------------------------------------------
func secondary_manage(delta):
	if (
		(p_is_dashing == false and p_weapon_controller.reloading == false) and 
		(not Input.is_action_pressed("primary_attack") or 
		(Input.is_action_pressed("primary_attack") and p_secondary_active == true))
		):
			
		p_secondary_active = p_secondary_controller.is_charging
		p_secondary_controller.secondary_controls(delta)


#---------------------------------------------------------------------------------------------------------------------------
#Player damage function
func player_hit_signalled(hurtbox: HurtboxComponent):
	if p_consecutive_dash == 0:
		#Calculate damage based on damage resistance (Damage resistance is a float while hurt damage is an int)
		@warning_ignore("narrowing_conversion")
		p_health_component.health -= hurtbox.hurt_damage / p_damage_resistance
		
		#Apply knockback to self
		if hurtbox.knockback_type == "center": 
			var angle := get_angle_to(hurtbox.global_position) + PI
			p_knockback_taken = Vector2.RIGHT.rotated(angle)
		elif hurtbox.knockback_type == "velocity":
			p_knockback_taken = hurtbox.get_parent().velocity.normalized()
		else:
			p_knockback_taken = Vector2.ZERO
		p_knockback_taken *= hurtbox.hurt_knockback
		
		p_hitbox_component.is_hit = true
		p_hitbox_component.hit_timer.start(p_hitbox_component.hit_delay)
		
		Camera.apply_camera_shake(16.0)
		Global.hit_stop(0.075)
		
		$PlaceholderSprite2D.self_modulate = Color("ff2121")
		await get_tree().create_timer(0.9, false).timeout
		$PlaceholderSprite2D.self_modulate = Color("ffffff")
		
	else:
		p_hitbox_component.hit_timer.start(0.1)


#---------------------------------------------------------------------------------------------------------------------------
#Player has 0 HP
func player_no_health():
	print("Player Died")
	Global.player_dead = true
	#get_tree().quit()


#---------------------------------------------------------------------------------------------------------------------------
#Player dash timer signal
func _on_dash_timer_timeout():
	p_consecutive_dash = 0
