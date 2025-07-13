############################## Test Enemy ##############################
extends Entity

#A test enemy to figure out how I'm going to implement enemies
@export var speed : float = 250.0

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	super._ready()


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	#If Area Of Sight returns with a target
	if area_of_sight.target != null:
		_navigation_check(Global.player_position, min_nav_time, max_nav_time)
		
		if can_navigate == true:
			#Navigate to player
			velocity = lerp(Vector2(
				velocity.x, velocity.y * 2), 
				current_agent_position.direction_to(next_path_position) * speed, Global.weighted_lerp(9, delta)
				)
			
			velocity.y /= 2
			velocity += knockback_taken
			knockback_taken = lerp(knockback_taken, Vector2.ZERO, Global.weighted_lerp(Global.knockback_ease, delta))
			move_and_slide()
	
	


#---------------------------------------------------------------------------------------------------------------------------
func no_health():
	super.no_health()
	queue_free()
