############################## Big Boss ##############################
extends Entity

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

@onready var CHARGE_PARTICLE = $ChargeParticles
const DUST_PARTICLE = preload("res://scenes/entity/particles/dust_splash1.tscn")
const SMALL_PULSE = preload("res://scenes/entity/particles/small_pulse.tscn")


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	super._ready()
	
	speed = DEFAULT_SPEED
	target_speed = DEFAULT_SPEED
	
	hurtbox_component.hurt_damage = DEFAULT_DAMAGE
	
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
	scale = Vector2(3.25, 3.25)


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
						
						timer = 0.0
					
					if speed >= CHARGE_SPEED - 5.0 and timer >= CHARGE_TIME:
						hurtbox_component.set_collision_layer_value(4, false)
						hurtbox_component.hurt_damage = DEFAULT_DAMAGE
						CHARGE_PARTICLE.emitting = false
						
						speed = CHARGE_SPEED / -2
						target_speed = DEFAULT_SPEED
						
						state = PURSUIT
						is_charging = false
						can_navigate = false
					
					timer += delta
					
					speed = lerp(speed, target_speed, Global.weighted_lerp(4, delta))
					target_speed += CHARGE_SPEED * delta
					target_speed = clamp(target_speed, 0, CHARGE_SPEED)
					
					velocity = Vector2(dir.x, dir.y * 2) * speed
				
				STUNNED:
					if is_stunned == false:
						is_stunned = true
						speed *= -1 
						target_speed = 0
						
						hurtbox_component.set_collision_layer_value(4, false)
						hurtbox_component.hurt_damage = DEFAULT_DAMAGE
						
						#Effects on impact
						CHARGE_PARTICLE.emitting = false
						var dust_scene = spawn_scene(DUST_PARTICLE, self)
						dust_scene.speed_scale = 1.5
						var pulse_scene = spawn_scene(SMALL_PULSE, self)
						pulse_scene.modulate = Color(1, 1, 1, 0.675)
						pulse_scene.scale = Vector2(1.6, 0.8)
						
						timer = 0.0
					
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


#---------------------------------------------------------------------------------------------------------------------------
func no_health():
	super.no_health()
	queue_free()


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
