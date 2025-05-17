############################## Brute Enemy ##############################
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

enum {
	PURSUIT,
	CHARGING, 
	STUNNED
}
var state = PURSUIT

@onready var CHARGE_PARTICLE = $ChargeParticles
const DUST_PARTICLE = preload("res://scenes/entity/particles/dust_splash1.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	super._ready()
	
	speed = DEFAULT_SPEED
	target_speed = DEFAULT_SPEED
	
	hurtbox_component.hurt_damage = 5
	
	CHARGE_PARTICLE.emitting = false
	
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
			_navigation_check(Global.player_position, 0.35, 0.65)
			
		else:
			can_navigate = true
		
		if can_navigate == true:
			match state:
				PURSUIT: #Pursuing the player, not charging
					speed = lerp(speed, target_speed, 0.3)
					
					#Navigate to player
					velocity = lerp(Vector2(
						velocity.x, velocity.y * 2), 
						current_agent_position.direction_to(next_path_position) * speed, 0.1
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
						hurtbox_component.hurt_damage = 8
						CHARGE_PARTICLE.emitting = true 
						
						timer = 0.0
					
					if speed >= CHARGE_SPEED - 5.0 and timer >= CHARGE_TIME:
						hurtbox_component.set_collision_layer_value(4, false)
						hurtbox_component.hurt_damage = 5
						CHARGE_PARTICLE.emitting = false
						
						speed = CHARGE_SPEED / -2
						target_speed = DEFAULT_SPEED
						
						state = PURSUIT
						is_charging = false
						can_navigate = false
					
					timer += delta
					
					speed = lerp(speed, target_speed, 0.6)
					target_speed += CHARGE_SPEED * delta
					target_speed = clamp(target_speed, 0, CHARGE_SPEED)
					
					velocity = Vector2(Vector2(dir.x, dir.y * 2) * speed)
				
				STUNNED:
					if is_stunned == false:
						is_stunned = true
						speed *= -1 
						target_speed = 0
						
						hurtbox_component.set_collision_layer_value(4, false)
						hurtbox_component.hurt_damage = 5
						CHARGE_PARTICLE.emitting = false
						
						var dust_scene = spawn_scene(DUST_PARTICLE, self)
						dust_scene.speed_scale = 1.5
						
						timer = 0.0
					
					timer += delta
					if timer >= CHARGE_TIME / 2:
						is_stunned = false
						speed = 0
						target_speed = DEFAULT_SPEED
						state = PURSUIT
						
						is_charging = false
						can_navigate = false
						
					
					speed = lerp(speed, target_speed, 0.15)
					
					velocity = Vector2(dir * speed)
			
			
			velocity.y /= 2
			velocity += knockback_taken
			
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
