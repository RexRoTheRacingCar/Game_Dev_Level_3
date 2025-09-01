############################## Turret Secondary ##############################
extends BaseSecondary

@onready var turret_barrel_1 : Sprite2D = %TurretBarrel1
@onready var turret_barrel_2 : Sprite2D = %TurretBarrel2
@onready var turret_barrel_3 : Sprite2D = %TurretBarrel3

@onready var range_area = %RangeArea
var target_array : Array = []
var target : Entity
var turret_position : Vector2

@onready var death_timer = %DeathTimer
@export var can_shoot : bool = false
@export var shoot_time : float = 1.0
var timer : float = 0

const BULLET = preload("res://scenes/entity/bullets/default_bullet.tscn")
const LANDING_PULSE = preload("res://scenes/entity/particles/small_pulse.tscn")
const DUST_SCENE = preload("res://scenes/entity/particles/dust_splash1.tscn")

const TURRET_IMPACT_SFX = preload("res://assets/audio/diegetic_sfx/turret_falls.mp3")
const TURRET_SHOT_SFX = preload("res://assets/audio/diegetic_sfx/turret_shot.mp3")
const TURRET_FALLING_WHOOSH_SFX = preload("res://assets/audio/diegetic_sfx/turret_falling_whoosh.mp3")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	global_position = Global.get_nav_mesh_point(Global.global_map, global_position, 10)
	Global.connect("reset_to_lobby", queue_free)
	Global.connect("room_changed", queue_free)
	range_area.connect("body_entered", body_entered)
	range_area.connect("body_exited", body_exited)
	death_timer.connect("timeout", turret_death)
	
	target_array = []
	shoot_time /= ((power_mult + 1.0) / 1.75)
	
	turret_position = global_position + Vector2(0, -34)
	turret_barrel_1.look_at(Global.player_position)
	turret_barrel_2.rotation = turret_barrel_1.rotation
	turret_barrel_3.rotation = turret_barrel_1.rotation
	
	AudioManager.play_2d_sound(TURRET_FALLING_WHOOSH_SFX, "SFX", global_position, true)


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta):
	if target_array.is_empty() == false:
		timer += delta
		
		var turret_dir : float = _get_angle_to_enemy()
		
		#Shoot when timer says so, reset timer afterwards
		if timer >= shoot_time and can_shoot == true:
			timer = 0.0
			
			_shoot_bullet(turret_dir, turret_position)


#---------------------------------------------------------------------------------------------------------------------------
func _get_angle_to_enemy():
	#Check for target
	if _check_target_array() == false:
		return
	
	#Find closest enemy to turret
	var aim_target : Entity
	var enemy_dist : float = 99999.9
	
	for enemy in range(0, target_array.size()):
		var dist = global_position.distance_to(target_array[enemy].global_position)
		if dist < enemy_dist:
			enemy_dist = dist
			aim_target = target_array[enemy]
	
	var distance : float = turret_position.distance_to(aim_target.global_position) / 950
	var target_pos : Vector2 = aim_target.global_position + aim_target.velocity * distance
	
	turret_barrel_1.look_at(target_pos)
	turret_barrel_2.rotation = turret_barrel_1.rotation
	turret_barrel_3.rotation = turret_barrel_1.rotation
	
	target_pos = target_pos - turret_position
	target_pos.y *= 2
	
	var dir = target_pos.angle()
	return dir


#---------------------------------------------------------------------------------------------------------------------------
#Check if target exists, return bool
func _check_target_array():
	for enemy in range(0, target_array.size() - 1):
		if is_instance_valid(target_array[enemy]) == false:
			target_array.erase(enemy)
	
	if target_array.is_empty() == false:
		return true
	return false


#---------------------------------------------------------------------------------------------------------------------------
func _shoot_bullet(dir : float, turret_pos : Vector2):
	#Instance bullet & aim at target. Predictive aiming.
	var new_bullet := BULLET.instantiate()
	
	#Bullet spawned
	new_bullet.global_position = Vector2.RIGHT.rotated(dir) * 50
	new_bullet.global_position.y /= 2
	new_bullet.global_position += turret_pos
	new_bullet.rotation = dir
	new_bullet.accuracy /= 3
	
	new_bullet.damage *= power_mult
	
	get_tree().root.get_node("/root/Game/").add_child(new_bullet)
	
	new_bullet.implement_stats()
	new_bullet.death_timer_node.start(new_bullet.lifetime * 1.6)
	
	_muzzle_flash()


#---------------------------------------------------------------------------------------------------------------------------
#Turret shoot animation
func _muzzle_flash():
	#Bullet Just Fired
	AudioManager.play_2d_sound(TURRET_SHOT_SFX, "SFX", global_position, true)
	turret_barrel_1.texture.region = Rect2(600, 400, 200, 100)
	
	turret_barrel_1.position = Vector2.RIGHT.rotated(turret_barrel_1.rotation) * -28
	turret_barrel_1.position.y -= 64
	turret_barrel_2.position = Vector2(turret_barrel_1.position.x, turret_barrel_1.position.y - 10)
	turret_barrel_3.position= Vector2(turret_barrel_1.position.x, turret_barrel_1.position.y - 20)
	
	#Post Bullet Fired
	var turret_1_tween = create_tween().set_parallel(true)
	turret_1_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	turret_1_tween.tween_property(turret_barrel_1, "position", Vector2(0, -64), shoot_time / 3).from_current()
	
	var turret_2_tween = create_tween().set_parallel(true)
	turret_2_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	turret_2_tween.tween_property(turret_barrel_2, "position", Vector2(0, -74), shoot_time / 3).from_current()
	
	var turret_3_tween = create_tween().set_parallel(true)
	turret_3_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	turret_3_tween.tween_property(turret_barrel_3, "position", Vector2(0, -84), shoot_time / 3).from_current()
	
	await get_tree().create_timer(shoot_time / 3, false).timeout
	
	turret_barrel_1.texture.region = Rect2(600, 300, 200, 100)


#When death timer runs out, delete turret
#---------------------------------------------------------------------------------------------------------------------------
func turret_death():
	crash_landed()
	queue_free()


#Turret has landed
#---------------------------------------------------------------------------------------------------------------------------
func crash_landed():
	#Particle effects
	var landing_particle = Global.spawn_particle(global_position, self, LANDING_PULSE)
	landing_particle.scale *= 2
	if GlobalSettings.limited_particles == false:
		Global.spawn_particle(global_position, self, DUST_SCENE)
	
	AudioManager.play_2d_sound(TURRET_IMPACT_SFX, "SFX", global_position, true)
	Camera.apply_camera_shake(9)
	
	timer = -shoot_time


#Enter & exit range
#---------------------------------------------------------------------------------------------------------------------------
func body_entered(body : Entity):
	target_array.append(body)


#---------------------------------------------------------------------------------------------------------------------------
func body_exited(body : Entity):
	target_array.erase(body)
