############################## Test Enemy ##############################
extends Entity

#A test enemy to figure out how I'm going to implement enemies
@export var speed : float = 250.0

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	super._ready()


#---------------------------------------------------------------------------------------------------------------------------
func _process(_delta: float) -> void:
	#If Area Of Sight returns with a target
	if area_of_sight.target != null:
		_navigation_check(Global.player_position, 0.3, 0.6)
		
		if can_navigate == true:
			#Navigate to player
			
			velocity = lerp(Vector2(
				velocity.x, velocity.y * 2), 
				current_agent_position.direction_to(next_path_position) * speed, 0.1
				)
			
			velocity.y /= 2
			velocity += knockback_taken
			
			move_and_slide()
