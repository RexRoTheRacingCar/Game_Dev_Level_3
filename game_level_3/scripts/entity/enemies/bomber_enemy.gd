############################## Bomber Enemy ##############################
extends Entity

@export var speed : float = 250.0
var target_pos : Vector2

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	super._ready()
	
	target_pos = Global.rand_nav_mesh_point(Global.global_map, 2, false)
	can_navigate = false


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(_delta: float) -> void:
	#If Area Of Sight returns with a target
	if area_of_sight.target != null:
		_navigation_check(target_pos, 0.35, 0.7)
		
		if global_position.distance_to(target_pos) <= 50.0:
			target_pos = Global.rand_nav_mesh_point(Global.global_map, 2, false)
			can_navigate = false
			_navigation_check(target_pos, 0.35, 0.7)
		
		
		if can_navigate == true:
			#Navigate to random point
			velocity = lerp(Vector2(
				velocity.x, velocity.y * 2), 
				current_agent_position.direction_to(next_path_position) * speed, 0.1
				)
			
			velocity.y /= 2
			velocity += knockback_taken
			
			move_and_slide()


#---------------------------------------------------------------------------------------------------------------------------
func no_health():
	super.no_health()
	queue_free()
