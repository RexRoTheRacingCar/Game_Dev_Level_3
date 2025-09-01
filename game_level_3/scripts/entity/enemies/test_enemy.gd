############################## Test Enemy ##############################
extends Entity

#A test enemy to figure out how I'm going to implement enemies
@export var speed : float = 250.0

const BASIC_HIT_SFX = preload("res://assets/audio/diegetic_sfx/enemies/basic_hit.mp3")
const BASIC_DEATH_SFX = preload("res://assets/audio/diegetic_sfx/enemies/basic_death.mp3")

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
		
		var check : bool = _check_player_position()
		if check == false:
			anim_tree["parameters/Movement/blend_amount"] = 0
		else:
			anim_tree["parameters/Movement/blend_amount"] = 1


#---------------------------------------------------------------------------------------------------------------------------
func hit_signalled(hurtbox : HurtboxComponent):
	super.hit_signalled(hurtbox)
	AudioManager.play_2d_sound(BASIC_HIT_SFX, "SFX", global_position, true)


#---------------------------------------------------------------------------------------------------------------------------
func no_health():
	super.no_health()
	AudioManager.play_2d_sound(BASIC_DEATH_SFX, "SFX", global_position, true)
	queue_free()
