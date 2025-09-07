############################## Big Boss ##############################
extends Entity


@export var pursuit_speed : float = 100.0
@export var charge_speed : float = 1250.0
var speed : float = 0.0
var target_speed : float = 0.0

var dir : Vector2 = Vector2.ZERO

var is_attacking : bool = false
var initial_attack : bool = false
var counter : int = 0

@export var when_to_attack : float = 8.0
var attack_timer : float = 0.0
var timer : float = 0.0

var double_time : bool = false
var is_dead : bool = false

enum BOSS_STATE {
	PURSUIT,
	CHARGING,
	SHOOT,
	BOMB_SHOOT,
	TELEPORT,
	CIRCLE_SHOOT,
	STUNNED,
}
var state = BOSS_STATE.PURSUIT

#Nodes 
@onready var wall_detection = $WallDetection

#Scenes
const GLOWING_BULLET = preload("res://scenes/entity/bullets/glowing_bullet.tscn")
const FLYING_BOMB = preload("res://scenes/entity/bullets/flying_bomb.tscn")
const WARNING_OUTLINE = preload("res://scenes/entity/warning_outline.tscn")
const EXPLOSION = preload("res://scenes/entity/secondaries/explosion.tscn")
const SMALL_PULSE = preload("res://scenes/entity/particles/small_pulse.tscn")
const TELEPORT_SCENE = preload("res://scenes/entity/particles/teleport_scene.tscn")
const DEATH_PULSE = preload("res://scenes/entity/secondaries/test_secondary.tscn")

#Audio
const BOMB_SHOOT_SFX = preload("res://assets/audio/diegetic_sfx/enemies/bomber_shoot.mp3")
const BOSS_HIT_SFX = preload("res://assets/audio/diegetic_sfx/enemies/boss_hit.mp3")
const BOSS_BIG_SHOT_SFX = preload("res://assets/audio/diegetic_sfx/enemies/boss_big_shot.mp3")
const BOSS_SHOOT_SFX = preload("res://assets/audio/diegetic_sfx/enemies/boss_shoot.mp3")
const BOSS_TELEPORT_SFX = preload("res://assets/audio/diegetic_sfx/enemies/mage_ability.mp3")
const BOSS_CHARGE_SFX = preload("res://assets/audio/diegetic_sfx/enemies/brute_charge.mp3")
const BOSS_IMPACT_SFX = preload("res://assets/audio/diegetic_sfx/enemies/brute_impact.mp3")
const BOSS_DEATH_SFX = preload("res://assets/audio/diegetic_sfx/enemies/boss_death.mp3")

#---------------------------------------------------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	randomize()
	
	is_attacking = false
	wall_detection.monitoring = false
	hurtbox_component.hurt_damage = 20


#---------------------------------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if area_of_sight.target != null:
		timer += delta
		if is_attacking == false:
			attack_timer += delta
		
		match state:
			#Boss pursue the player
			BOSS_STATE.PURSUIT:
				_navigation_check(Global.player_position, min_nav_time, max_nav_time)
				speed = lerp(speed, pursuit_speed, Global.weighted_lerp(25, delta))
				
				if attack_timer > when_to_attack:
					_boss_attack()
				
				_boss_navigate(delta)
				
				var check : bool = _check_player_position()
				if check == false:
					anim_tree["parameters/Movement/blend_amount"] = 0
				else:
					anim_tree["parameters/Movement/blend_amount"] = 1
				
				anim_tree["parameters/TimeScale/scale"] = clamp(speed / 100, 0.0, 4.0)
			
			#Boss charge at player
			BOSS_STATE.CHARGING:
				if initial_attack == true:
					var distance : float = global_position.distance_to(Global.player_position) / 1000
					var target_pos : Vector2 = Global.player_position + Global.player_velocity * distance
					dir = global_position.direction_to(target_pos)
					
					wall_detection.monitoring = true
					hurtbox_component.set_collision_layer_value(4, true)
					
					AudioManager.play_2d_sound(BOSS_CHARGE_SFX, "SFX", global_position, true)
					
					velocity = Vector2.ZERO
					speed = 0.0
					attack_timer = 0.0
					
					initial_attack = false
				
				speed = lerpf(speed, target_speed, Global.weighted_lerp(4.0, delta))
				target_speed += charge_speed * delta
				target_speed = clamp(target_speed, 0, charge_speed)
				
				velocity = dir * speed
				
				attack_timer += delta
				if attack_timer > 0.5:
					_burst_fire_bombs(Global.rand_nav_mesh_point(Global.global_map, 2, false))
					
					attack_timer = randf_range(0.0, 0.1)
					counter += 1
				
				if counter > 8:
					state = BOSS_STATE.PURSUIT
					initial_attack = true
					hurtbox_component.set_collision_layer_value(4, false)
				
				var check : bool = _check_player_position()
				if check == false:
					anim_tree["parameters/Movement/blend_amount"] = 0
				else:
					anim_tree["parameters/Movement/blend_amount"] = 1
				
				anim_tree["parameters/TimeScale/scale"] = clamp(speed / 100, 0.0, 4.0)
			
			#Boss is stunned after charge
			BOSS_STATE.STUNNED:
				if initial_attack == true:
					speed *= -1.5
					target_speed = 0
					
					initial_attack = false
					wall_detection.monitoring = false
					hurtbox_component.set_collision_layer_value(4, false)
					
					AudioManager.play_2d_sound(BOSS_IMPACT_SFX, "SFX", global_position, true)
					_dust_pulse(2.75)
					
					anim_tree["parameters/TimeScale/scale"] = 1.0
					anim_tree["parameters/StunOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
				
				speed = lerp(speed, target_speed, Global.weighted_lerp(8, delta))
				velocity = Vector2(dir * speed)
				
				attack_timer += delta
				
				if attack_timer > 1.5:
					state = BOSS_STATE.PURSUIT
					
					attack_timer = 0.0
					is_attacking = false
			
			#Boss shoot in player's direction
			BOSS_STATE.SHOOT:
				if initial_attack == true:
					attack_timer = -1.25
					
					initial_attack = false
				
				attack_timer += delta
				speed = lerp(speed, pursuit_speed / 1.5, Global.weighted_lerp(4, delta))
				
				_navigation_check(Global.player_position, min_nav_time, max_nav_time)
				_boss_navigate(delta)
				
				if attack_timer > 0.1:
					attack_timer = 0
					counter += 1
					
					AudioManager.play_2d_sound(BOSS_SHOOT_SFX, "SFX", global_position, true)
					_dust_pulse(1.5)
					
					var player_distance : float = global_position.distance_to(Global.player_position) / 750
					var target_pos : Vector2 = Global.player_position + (Global.player_velocity / 2) * player_distance
					
					target_pos = target_pos - global_position
					target_pos.y *= 2
					var shoot_dir = target_pos.angle() + ((PI / 5) * sin(2.5 * timer))
					
					_shoot_bullet(shoot_dir)
				
				#Reset to pursuit
				if counter > 55:
					state = BOSS_STATE.PURSUIT
					
					attack_timer = 0.0
					is_attacking = false
				
				var check : bool = _check_player_position()
				if check == false:
					anim_tree["parameters/Movement/blend_amount"] = 0
				else:
					anim_tree["parameters/Movement/blend_amount"] = 1
				
				anim_tree["parameters/TimeScale/scale"] = clamp(speed / 130, 0.0, 4.0)
			
			#Boss shoot in circle
			BOSS_STATE.CIRCLE_SHOOT:
				if initial_attack == true:
					attack_timer = -1.0
					
					initial_attack = false
				
				attack_timer += delta
				speed = lerp(speed, pursuit_speed / 1.75, Global.weighted_lerp(4, delta))
				
				_navigation_check(Global.player_position, min_nav_time, max_nav_time)
				_boss_navigate(delta)
				
				#Shoot ring of bullets
				if attack_timer > 0.75:
					attack_timer = 0
					counter += 1
					
					AudioManager.play_2d_sound(BOSS_BIG_SHOT_SFX, "SFX", global_position, true)
					_dust_pulse(2.25)
					
					for bullet in range(0, 18):
						var shoot_dir = (((2 * PI) / 18) * bullet) + timer
						_shoot_bullet(shoot_dir)
				
				if counter > 2:
					state = BOSS_STATE.PURSUIT
					
					attack_timer = 0.0
					is_attacking = false
					
				var check : bool = _check_player_position()
				if check == false:
					anim_tree["parameters/Movement/blend_amount"] = 0
				else:
					anim_tree["parameters/Movement/blend_amount"] = 1
				
				anim_tree["parameters/TimeScale/scale"] = clamp(speed / 130, 0.0, 4.0)
			
			#Bombs shoot everywhere
			BOSS_STATE.BOMB_SHOOT:
				if initial_attack == true:
					attack_timer = -1.0
					
					initial_attack = false
				
				attack_timer += delta
				speed = lerp(speed, 0.0, Global.weighted_lerp(3, delta))
				
				_navigation_check(Global.player_position, min_nav_time, max_nav_time)
				_boss_navigate(delta)
				
				#Shoot the bombs in the air
				if attack_timer > 1.0 and counter <= 2:
					counter += 1
					
					for bombs in randi_range(2, 3):
						attack_timer = 0
						
						_burst_fire_bombs(Global.rand_nav_mesh_point(Global.global_map, 2, false))
						_burst_fire_bombs(Global.player_position)
						
						anim_tree["parameters/TimeScale/scale"] = 4.0
						anim_tree["parameters/StunOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
						
						await get_tree().create_timer(randf_range(0.15, 0.4), false).timeout
					
				#Charge at player, then reset
				if counter > 2 and attack_timer > 0.75:
					attack_timer = 0
					state = BOSS_STATE.TELEPORT
					
					initial_attack = true
				
				var check : bool = _check_player_position()
				if check == false:
					anim_tree["parameters/Movement/blend_amount"] = 0
				else:
					anim_tree["parameters/Movement/blend_amount"] = 1
				
			BOSS_STATE.TELEPORT:
				#Teleport to random position
				if initial_attack == true and attack_timer > 1.0:
					initial_attack = false
					_teleport()
				
				attack_timer += delta
				
				speed = lerp(speed, 0.0, Global.weighted_lerp(4, delta))
			
				_navigation_check(Global.player_position, min_nav_time, max_nav_time)
				_boss_navigate(delta)
				
				var check : bool = _check_player_position()
				if check == false:
					anim_tree["parameters/Movement/blend_amount"] = 0
				else:
					anim_tree["parameters/Movement/blend_amount"] = 1
				
				anim_tree["parameters/TimeScale/scale"] = clamp(speed / 100, 0.0, 4.0)
				
				if initial_attack == false and attack_timer > 4.0:
					state = BOSS_STATE.PURSUIT
					
					attack_timer = 0.0
					is_attacking = false
		
		#Movement
		velocity.y /= 2
		velocity += knockback_taken
		knockback_taken = lerp(knockback_taken, Vector2.ZERO, Global.weighted_lerp(Global.knockback_ease, delta))
		move_and_slide()


#---------------------------------------------------------------------------------------------------------------------------
func _boss_attack():
	attack_timer = 0.0
	is_attacking = true
	initial_attack = true
	
	counter = 0
	
	var distance : float = global_position.distance_to(Global.player_position)
	var select_rand_attack : float = randf()
	
	if distance < 300:
		if select_rand_attack < 0.33:
			state = BOSS_STATE.CIRCLE_SHOOT
		
		elif select_rand_attack < 0.66:
			state = BOSS_STATE.CHARGING
		
		else:
			state = BOSS_STATE.TELEPORT
	
	else:
		if select_rand_attack < 0.33:
			state = BOSS_STATE.CHARGING
		
		elif select_rand_attack < 0.66:
			state = BOSS_STATE.SHOOT
		
		else:
			state = BOSS_STATE.BOMB_SHOOT
	
	if randf() < 0.2:
		Global.emit_signal("summon_enemies_for_boss")


#---------------------------------------------------------------------------------------------------------------------------
func _shoot_bullet(bullet_dir : float):
	#Find bullet angle
	var new_bullet = GLOWING_BULLET.instantiate()
	
	#Apply variables to newly instanced bullet
	new_bullet.accuracy = 0
	new_bullet.rotation = bullet_dir
	new_bullet.initial_speed = 750
	new_bullet.target_speed = 750
	
	var position_offset : Vector2 = Vector2.RIGHT.rotated(bullet_dir) * 80
	position_offset.y /= 2
	new_bullet.global_position = global_position + position_offset
	
	#Add bullet to tree
	get_tree().root.get_node("/root/Game/").add_child(new_bullet)
	
	new_bullet.implement_stats()
	new_bullet.death_timer_node.start(2.5)


#---------------------------------------------------------------------------------------------------------------------------
func _burst_fire_bombs(target_position : Vector2):
	var new_bomb = FLYING_BOMB.instantiate()
	#Bomb positioning
	new_bomb.spawn_pos = global_position
	new_bomb.target_pos = target_position
	new_bomb.warning_scene = WARNING_OUTLINE
	new_bomb.explosion_scene = EXPLOSION
	#Bomb airtime
	new_bomb.air_time = global_position.distance_to(new_bomb.target_pos) / 400
	new_bomb.air_time = clamp(new_bomb.air_time, 1.5, 4.0)
	new_bomb.warning_time = new_bomb.air_time / 4
	#Bomb scale
	var rand_scale = randf_range(1.5, 2.0)
	new_bomb.explosion_scale = Vector2(rand_scale, rand_scale / 2)
	
	get_tree().root.get_node("/root/Game/").call_deferred("add_child", new_bomb)
	
	AudioManager.play_2d_sound(BOMB_SHOOT_SFX, "SFX", global_position, true)
	_dust_pulse(1.75)


#---------------------------------------------------------------------------------------------------------------------------
func _dust_pulse(scale_mult : float):
	var pulse_scene = spawn_scene(SMALL_PULSE, self.get_parent())
	pulse_scene.modulate = Color(1, 1, 1)
	pulse_scene.scale = Vector2(1, 0.5) * scale_mult
	pulse_scene.global_position = global_position


#---------------------------------------------------------------------------------------------------------------------------
#Teleport to random position
func _teleport():
	var new_pos : Vector2 = Global.rand_nav_mesh_point(Global.global_map, 2, false)
	var teleport_1 = spawn_scene(TELEPORT_SCENE, get_tree().root.get_node("/root/Game/"))
	teleport_1.global_position = global_position
	teleport_1.scale *= 1.5
	teleport_1.modulate = Color(0.108, 0.83, 0.637)
	
	var teleport_2 = spawn_scene(TELEPORT_SCENE, get_tree().root.get_node("/root/Game/"))
	teleport_2.global_position = new_pos
	teleport_2.scale *= 1.5
	teleport_2.modulate = Color(0.108, 0.83, 0.637)
	
	var TWEEN_TIME : float = 0.6
	
	var sprite_tween_1 = create_tween()
	sprite_tween_1.tween_property(sprite, "modulate", Color(0, 0.6, 0.45), TWEEN_TIME / 2).from_current()
	
	await get_tree().create_timer(TWEEN_TIME, false).timeout
	
	#THE TELEPORT & EXPLOSION
	var old_pos : Vector2 = global_position
	global_position = new_pos
	_spawn_magic_explosion(old_pos, false)
	_spawn_magic_explosion(new_pos, false)
	
	knockback_taken = Vector2.ZERO
	
	Global.emit_signal("summon_enemies_for_boss")
	
	var sprite_tween_2 = create_tween()
	sprite_tween_2.tween_property(sprite, "modulate", Color(1, 1, 1), TWEEN_TIME / 2).from_current()


#---------------------------------------------------------------------------------------------------------------------------
func _spawn_magic_explosion(pos : Vector2, damage : bool):
	var new_explosion = spawn_scene(EXPLOSION, get_tree().root.get_node("/root/Game/"))
	new_explosion.global_position = pos
	new_explosion.power_mult = 1.0
	new_explosion.modulate = Color(0.13, 1.0, 0.54)
	new_explosion.anim_player.speed_scale = 0.35
	if damage == false:
		new_explosion.hurtbox.set_collision_layer_value(2, false)
		new_explosion.hurtbox.set_collision_layer_value(4, false)
		new_explosion.spawn_audio = BOSS_TELEPORT_SFX
	
	return new_explosion


#---------------------------------------------------------------------------------------------------------------------------
func _boss_navigate(delta : float):
	if can_navigate == true:
		#Navigate to player
		velocity = lerp(Vector2(
			velocity.x, velocity.y * 2), 
			current_agent_position.direction_to(next_path_position) * speed, Global.weighted_lerp(8, delta)
			)


#---------------------------------------------------------------------------------------------------------------------------
func _reset_boss_to_pursuit():
	state = BOSS_STATE.PURSUIT
	is_attacking = false
	initial_attack = false


#---------------------------------------------------------------------------------------------------------------------------
func hit_signalled(hurtbox : HurtboxComponent):
	super.hit_signalled(hurtbox)
	
	AudioManager.play_2d_sound(BOSS_HIT_SFX, "SFX", global_position, true)
	
	if health_component.health <= int(float(health_component.max_health) / 2) and double_time == false:
		when_to_attack = 1.75
		hurtbox_component.hurt_damage = 30
		
		Global.emit_signal("summon_enemies_for_boss")


#---------------------------------------------------------------------------------------------------------------------------
func no_health():
	if is_dead == false:
		is_dead = true
		super.no_health()
		
		_dust_pulse(2)
		_dust_pulse(5)
		_dust_pulse(11)
		
		AudioManager.play_2d_sound(BOSS_DEATH_SFX, "SFX", global_position, true)
		Global.emit_signal("kill_all_enemies")
		
		Global.gems += 10
		
		queue_free()


#---------------------------------------------------------------------------------------------------------------------------
func _on_wall_detection_body_entered(body):
	if state == BOSS_STATE.CHARGING and body.is_in_group("blocked"):
		attack_timer = 0.0
		state = BOSS_STATE.STUNNED
		initial_attack = true
