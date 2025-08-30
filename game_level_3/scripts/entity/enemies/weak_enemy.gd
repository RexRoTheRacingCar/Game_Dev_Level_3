############################## Weak Enemy ##############################
extends Entity

#Similar to Test Enemy 
@export var speed : float = 400.0
const DUST_SCENE = preload("res://scenes/entity/particles/dust_splash1.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	super._ready()
	
	await get_tree().physics_frame
	
	var new_dust = spawn_scene(DUST_SCENE, get_tree().root.get_node("/root/Game/"))
	new_dust.global_position = self.global_position
	new_dust.modulate = Color(1, 0, 0)


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	#If Area Of Sight returns with a target
	if area_of_sight.target != null:
		_navigation_check(Global.player_position, min_nav_time, max_nav_time)
		
		if can_navigate == true:
			#Navigate to player
			velocity = lerp(Vector2(
				velocity.x, velocity.y * 2), 
				current_agent_position.direction_to(next_path_position) * speed, Global.weighted_lerp(4, delta)
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
func no_health():
	super.no_health()
	#Spawn dust particles on death
	var new_scene = spawn_scene(DUST_SCENE, get_tree().root.get_node("/root/Game/"))
	new_scene.global_position = global_position
	new_scene.modulate = Color(0, 0, 0)
	
	queue_free()
