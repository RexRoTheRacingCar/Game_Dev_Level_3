############################## Big Boss ##############################
extends Entity


@export var pursuit_speed : float = 100.0
var speed : float = 0.0


enum BOSS_STATE {
	PURSUIT,
	CHARGE,
	STUNNED, 
	
}
var state = BOSS_STATE.PURSUIT


#---------------------------------------------------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	randomize()


#---------------------------------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if area_of_sight.target != null:
		match state:
			BOSS_STATE.PURSUIT:
				_navigation_check(Global.player_position, min_nav_time, max_nav_time)
				
				speed = lerp(speed, pursuit_speed, Global.weighted_lerp(22, delta))
				
			BOSS_STATE.CHARGE:
				pass
				
			BOSS_STATE.STUNNED:
				pass
		
		_move_boss(delta)


#---------------------------------------------------------------------------------------------------------------------------
func _move_boss(delta : float):
	if can_navigate == true:
		#Navigate to player
		velocity = lerp(Vector2(
			velocity.x, velocity.y * 2), 
			current_agent_position.direction_to(next_path_position) * speed, Global.weighted_lerp(8, delta)
			)
		
		velocity.y /= 2
		velocity += knockback_taken
		knockback_taken = lerp(knockback_taken, Vector2.ZERO, Global.weighted_lerp(Global.knockback_ease, delta))
		move_and_slide()
