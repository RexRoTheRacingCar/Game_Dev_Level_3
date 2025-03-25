############################## Target Raycast ##############################
extends RayCast2D
class_name TargetRaycast


#Variables
@export var min_target_distance : float
@export var max_target_distance : float


#---------------------------------------------------------------------------------------------------------------------------
#Check if target is between min and max range and is not blocked by a wall
func target_check(target_place : Vector2, parent_pos : Vector2) -> bool:
	target_position = target_place
	
	#Check if ray is colliding
	if is_colliding() == true:
		var object = get_collider()
		
		#Check if ray is colliding with walls
		if object.is_in_group("walls") == false:
			#Calculate ray distance
			var distance = sqrt((target_place.x - parent_pos.x)**(2.0) + (target_place.y - parent_pos.y)**(2))
			
			#Check if ray is within max and min parameters
			if distance < max_target_distance and distance > min_target_distance:
				return true
	
	return false
