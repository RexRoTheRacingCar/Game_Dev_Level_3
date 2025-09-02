############################## Big Boss ##############################
extends Entity


@export var pursuit_speed : float = 100.0
var speed : float = 0.0

var is_attacking : bool = false


@export var when_to_attack : float = 8.0
var attack_timer : float = 0.0

enum BOSS_STATE {
	PURSUIT,
	CHARGE,
	SHOOT,
	BOMB_SHOOT,
	PULSE,
	CIRCLE_SHOOT,
}
var state = BOSS_STATE.PURSUIT


#---------------------------------------------------------------------------------------------------------------------------
func _ready() -> void:
	super._ready()
	randomize()
	
	is_attacking = false


#---------------------------------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if area_of_sight.target != null:
		if is_attacking == false:
			attack_timer += delta
		
		match state:
			BOSS_STATE.PURSUIT:
				_navigation_check(Global.player_position, min_nav_time, max_nav_time)
				speed = lerp(speed, pursuit_speed, Global.weighted_lerp(22, delta))
				
				if attack_timer > when_to_attack:
					_boss_attack()
				
			BOSS_STATE.CHARGE:
				pass
		
		_move_boss(delta)


#---------------------------------------------------------------------------------------------------------------------------
func _boss_attack():
	attack_timer = randf_range(0.0, 2.0)
	is_attacking = true
	
	var distance : float = global_position.distance_to(Global.player_position)
	var select_rand_attack : float = randf()
	
	if distance < 400:
		if select_rand_attack < 0.5:
			state = BOSS_STATE.PULSE
		
		else:
			state = BOSS_STATE.CIRCLE_SHOOT
	
	else:
		if select_rand_attack < 0.33:
			state = BOSS_STATE.CHARGE
		
		elif select_rand_attack < 0.66:
			state = BOSS_STATE.SHOOT
		
		else:
			state = BOSS_STATE.BOMB_SHOOT


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


#---------------------------------------------------------------------------------------------------------------------------
func _reset_boss_to_pursuit():
	state = BOSS_STATE.PURSUIT
	is_attacking = false


#---------------------------------------------------------------------------------------------------------------------------
func no_health():
	super.no_health()
	queue_free()
