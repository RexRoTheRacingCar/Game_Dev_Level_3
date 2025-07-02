############################## Player Weapon ##############################
extends Node2D
class_name WeaponController

@export var current_weapon : WeaponType
@onready var reload_label = $Reloading
@onready var shoot_timer = $ShootTimer

var reloading : bool = false
var can_shoot : bool = true
var ammo : int = 0

var bullet_upgrade_array : Array = []


#Variables fetched from WeaponType resource, can be modified through upgrades
var spread_amount : float = 15.0
var bullet_amount : int : 
	set(new_value): #Update the bullet spread basd on bullet amount
		bullet_amount = new_value
		@warning_ignore("integer_division")
		spread_amount = ((spread_amount * bullet_amount) - spread_amount) / (bullet_amount * 1.5)
var burst_amount : int
var firerate : float
var reload_time : float
var max_ammo : int
var defualt_max_ammo : int
var default 

var bullet_scene : PackedScene
var camera_shake : float


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	_load_default_values()
	
	can_shoot = true
	reloading = false
	reload_label.visible = false
	
	ammo = max_ammo
	bullet_upgrade_array = []


#---------------------------------------------------------------------------------------------------------------------------
func _load_default_values():
	bullet_amount = current_weapon.default_bullet_amount
	spread_amount = current_weapon.default_spread
	burst_amount = current_weapon.default_burst_amount
	firerate = current_weapon.default_firerate
	reload_time = current_weapon.default_reload_time
	max_ammo = current_weapon.default_max_ammo
	
	bullet_scene = current_weapon.default_bullet
	camera_shake = current_weapon.camera_shake


#---------------------------------------------------------------------------------------------------------------------------
func weapon_controls(secondary_active):
	#Reloading functionality
	if (
		(Input.is_action_just_pressed("reload") or (Input.is_action_just_pressed("primary_attack") and ammo <= 0)) and
		reloading == false and 
		secondary_active == false
		):
		
		reload_label.visible = true
		reloading = true
		
		await get_tree().create_timer(current_weapon.default_reload_time, false).timeout
		
		reload_label.visible = false
		reloading = false
		ammo = max_ammo
	
	#Shooting functionality
	if Input.is_action_pressed("primary_attack") and can_shoot == true and reloading == false and secondary_active == false:
		for _n in range(0, burst_amount):
			if ammo >= 1:
				player_shoot()
				
			await get_tree().create_timer(firerate / (burst_amount), false).timeout
	
	#Update global variables
	Global.player_ammo = ammo
	Global.player_max_ammo = max_ammo


#---------------------------------------------------------------------------------------------------------------------------
#Player Shoot Function
func player_shoot():
	Camera.apply_camera_shake(camera_shake)
	
	can_shoot = false
	ammo -= 1
	shoot_timer.stop()
	shoot_timer.start(firerate)
	
	#The bullet instance
	for bullet in range(0, bullet_amount):
		var bullet_instance := bullet_scene.instantiate()
		var mouse_pos := get_global_mouse_position()
		var mouse_dir : Vector2 = mouse_pos - global_position
		mouse_dir.y *= 2
		
		#Bullet spawned
		bullet_instance.global_position = global_position
		bullet_instance.rotation = mouse_dir.angle()
		get_tree().root.get_node("/root/Game/").add_child(bullet_instance)
		
		#Bullet rotation offset based on amount of bullets fired
		@warning_ignore("integer_division")
		var bullet_rotation_offset = bullet - (bullet_amount / 2)
		if bullet_rotation_offset % 1: 
			bullet_rotation_offset = -bullet_rotation_offset
		bullet_instance.rotation += deg_to_rad(spread_amount) * bullet_rotation_offset
		
		#Apply upgrades to bullet
		for upgrades in bullet_upgrade_array:
			upgrades.apply_upgrade(bullet_instance)
		
		bullet_instance.implement_stats()
		bullet_instance.death_timer_node.start(bullet_instance.lifetime)


#---------------------------------------------------------------------------------------------------------------------------
#Shoot timer ended
func _on_shoot_timer_timeout():
	can_shoot = true
