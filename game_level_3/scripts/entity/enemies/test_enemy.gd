############################## Test Enemy ##############################
extends Entity

#A test enemy to figure out how I'm going to implement enemies

#Coin variables
var coin_range : int
var coin_scene : PackedScene = preload("res://scenes/entity/coin.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	coin_range = randi_range(3, 6)
	
	can_navigate = false
	current_agent_position = global_position
	next_path_position = navigation_agent.get_next_path_position()
	navigation_agent.target_position = Global.player_position
	
	#Signals
	health_component.zero_health.connect(no_health)
	hitbox_component.hitbox_entered.connect(hit_signalled)



#---------------------------------------------------------------------------------------------------------------------------
func _process(_delta: float) -> void:
	#If Area Of Sight returns with a target
	if area_of_sight.target != null:
		_navigation_check(Global.player_position, 0.25, 0.65)
		
		if can_navigate == true:
			#Navigate to player
			velocity = lerp(Vector2(
				velocity.x, velocity.y * 2), 
				current_agent_position.direction_to(next_path_position) * 250, 0.15
				)
			velocity.y /= 2
			velocity += knockback_taken
			
			move_and_slide()


#---------------------------------------------------------------------------------------------------------------------------
#Enemy has 0 HP
func no_health():
	for _n in range(0, coin_range): #Spawn coins at death position
		var new_coin = spawn_scene(coin_scene, self.get_parent())
		var rand_spawn : float = 30.0
		new_coin.global_position = Vector2(
			global_position.x + randf_range(rand_spawn, -rand_spawn), 
			global_position.y + randf_range(rand_spawn / 2, -rand_spawn / 2)
			)
	
	Camera.apply_camera_shake(shake_on_hit * 1.35)
	
	queue_free()
