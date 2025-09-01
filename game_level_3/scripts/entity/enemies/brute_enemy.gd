############################## Brute Enemy ##############################
extends Entity


@onready var wall_collision = %WallCollision

@export var DEFAULT_SPEED : float = 175.0
@export var CHARGE_SPEED : float = 800.0
var speed : float = 150.0
var target_speed : float = 150.0

@export var CHARGE_TIME : float = 1.2
var is_stunned : bool = false
var is_charging : bool = false
var detecting : bool = false

var dir := Vector2.ZERO
var timer : float = 0.0

@export var DEFAULT_DAMAGE : int = 6
@export var CHARGE_DAMAGE : int = 10

enum {
	PURSUIT,
	CHARGING, 
	STUNNED
}
var state = PURSUIT

var audio_timer_reset : float = 0.1
var audio_timer : float = -0.3

@onready var CHARGE_PARTICLE = $ChargeParticles
const DUST_PARTICLE = preload("res://scenes/entity/particles/dust_splash1.tscn")
const SMALL_PULSE = preload("res://scenes/entity/particles/small_pulse.tscn")
const AURA_PARTICLE = preload("res://scenes/entity/particles/aura_particle.tscn")

const BRUTE_HIT_SFX = preload("res://assets/audio/diegetic_sfx/enemies/brute_hit.mp3")
const BRUTE_DEATH_SFX = preload("res://assets/audio/diegetic_sfx/enemies/brute_death.mp3")
const BRUTE_CHARGE_SFX = preload("res://assets/audio/diegetic_sfx/enemies/brute_charge.mp3")
const BRUTE_IMPACT_SFX = preload("res://assets/audio/diegetic_sfx/enemies/brute_impact.mp3")
const BRUTE_STEP_SFX = preload("res://assets/audio/diegetic_sfx/enemies/brute_step.mp3")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	super._ready()
	
	speed = DEFAULT_SPEED
	target_speed = DEFAULT_SPEED
	
	hurtbox_component.hurt_damage = DEFAULT_DAMAGE
	wall_collision.monitoring = false
	
	CHARGE_PARTICLE.emitting = false
	if GlobalSettings.limited_particles == true:
		CHARGE_PARTICLE.amount = round(CHARGE_PARTICLE.amount / 2)
	
	state = PURSUIT
	
	is_stunned = false
	is_charging = false
	los_check = false
	detecting = false
	
	dir = Vector2.ZERO
	timer = 0.0


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	#If Area Of Sight returns with a target
	if area_of_sight.target != null:
		if state != CHARGING:
			_navigation_check(Global.player_position, min_nav_time, max_nav_time)
			
		else:
			can_navigate = true
		
		if can_navigate == true:
			match state:
				PURSUIT: #Pursuing the player, not charging
					speed = lerp(speed, target_speed, Global.weighted_lerp(16, delta))
					
					#Navigate to player
					velocity = lerp(Vector2(
						velocity.x, velocity.y * 2), 
						current_agent_position.direction_to(next_path_position) * speed, 
						Global.weighted_lerp(6, delta)
						)
						
					if detecting == true and line_of_sight.target_check(Global.player_position - global_position, global_position) == true:
						state = CHARGING
						is_charging = false
						speed = 0
						detecting = false
				
				CHARGING:
					if is_charging == false:
						is_charging = true
						dir = global_position.direction_to(Global.player_position)
						velocity = Vector2.ZERO
						
						hurtbox_component.set_collision_layer_value(4, true)
						hurtbox_component.hurt_damage = CHARGE_DAMAGE
						CHARGE_PARTICLE.emitting = true
						wall_collision.monitoring = true
						
						var aura_particles = spawn_scene(AURA_PARTICLE, get_tree().root.get_node("/root/Game/"))
						aura_particles.global_position = global_position
						aura_particles.z_index = 1
						aura_particles.modulate = Color(0.68, 0.717, 1.0)
						
						AudioManager.play_2d_sound(BRUTE_CHARGE_SFX, "SFX", global_position, true)
						
						timer = 0.0
					
					if speed >= CHARGE_SPEED - 5.0 and timer >= CHARGE_TIME:
						hurtbox_component.set_collision_layer_value(4, false)
						hurtbox_component.hurt_damage = DEFAULT_DAMAGE
						CHARGE_PARTICLE.emitting = false
						wall_collision.monitoring = false
						
						speed = CHARGE_SPEED / -2
						target_speed = DEFAULT_SPEED
						
						state = PURSUIT
						is_charging = false
						can_navigate = false
						
					timer += delta
					
					speed = lerpf(speed, target_speed, Global.weighted_lerp(3.0, delta))
					target_speed += CHARGE_SPEED * delta
					target_speed = clamp(target_speed, 0, CHARGE_SPEED)
					
					audio_timer += speed / 8000
					
					if audio_timer > audio_timer_reset:
						AudioManager.play_2d_sound(BRUTE_STEP_SFX, "SFX", global_position, true)
						audio_timer = 0.0
						audio_timer_reset += 0.1
					
					velocity = Vector2(dir.x, dir.y * 2) * speed
					
				STUNNED:
					if is_stunned == false:
						is_stunned = true
						speed *= -1
						target_speed = 0
						
						hurtbox_component.set_collision_layer_value(4, false)
						hurtbox_component.hurt_damage = DEFAULT_DAMAGE
						wall_collision.monitoring = false
						
						#Effects on impact
						CHARGE_PARTICLE.emitting = false
						var dust_scene = spawn_scene(DUST_PARTICLE, self)
						dust_scene.speed_scale = 1.5
						var pulse_scene = spawn_scene(SMALL_PULSE, self)
						pulse_scene.modulate = Color(1, 1, 1, 0.675)
						pulse_scene.scale = Vector2(1.8, 0.9)
						
						timer = 0.0
						audio_timer_reset = 0.1
						audio_timer = -0.3
					
					timer += delta
					if timer >= CHARGE_TIME / 2:
						is_stunned = false
						speed = 0
						target_speed = DEFAULT_SPEED
						state = PURSUIT
						
						is_charging = false
						can_navigate = false
					
					speed = lerp(speed, target_speed, Global.weighted_lerp(17, delta))
					velocity = Vector2(dir * speed)
			
			velocity.y /= 2
			velocity += knockback_taken
			knockback_taken = lerp(knockback_taken, Vector2.ZERO, Global.weighted_lerp(Global.knockback_ease, delta))
			move_and_slide()
		
		var check : bool = _check_player_position()
		if check == false:
			anim_tree["parameters/Movement/blend_amount"] = 0
		else:
			anim_tree["parameters/Movement/blend_amount"] = 1
		
		anim_tree["parameters/TimeScale/scale"] = (speed / 40)


#---------------------------------------------------------------------------------------------------------------------------
func no_health():
	super.no_health()
	AudioManager.play_2d_sound(BRUTE_DEATH_SFX, "SFX", global_position, true)
	queue_free()


#---------------------------------------------------------------------------------------------------------------------------
func hit_signalled(hurtbox : HurtboxComponent):
	super.hit_signalled(hurtbox)
	AudioManager.play_2d_sound(BRUTE_HIT_SFX, "SFX", global_position, true)


#---------------------------------------------------------------------------------------------------------------------------
func _on_charge_detection_body_entered(body: Node2D) -> void:
	#If colliding with player, is pursuing, and can see player with LOS; CHARGE!
	if body is Player and state == PURSUIT:
		detecting = true


#---------------------------------------------------------------------------------------------------------------------------
func _on_wall_collision_body_entered(body: Node2D) -> void:
	if state == CHARGING and body.is_in_group("blocked"):
		state = STUNNED
		is_stunned = false
		
		AudioManager.play_2d_sound(BRUTE_IMPACT_SFX, "SFX", global_position, true)
		audio_timer_reset = 0.1
		audio_timer = -0.3
