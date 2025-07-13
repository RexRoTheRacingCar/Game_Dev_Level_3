############################## Line of Sight ##############################
extends RayCast2D
class_name LineOfSight

#Variables
@export var min_target_distance : float
@export var max_target_distance : float

#---------------------------------------------------------------------------------------------------------------------------
#Check if target is between min and max range and is not blocked by a wall
func target_check(target_place : Vector2, parent_pos : Vector2) -> bool:
	enabled = true
	target_position = target_place
	
	#Check if ray is colliding
	if is_colliding() == true:
		var object = get_collider()
		
		if object == null: #If collider is null
			return false
		
		#Check if ray is colliding with walls
		if object.is_in_group("walls") == false and is_instance_valid(object) == true:
			#Find ray distance
			var distance = parent_pos.distance_to(target_place)
			
			#Check if ray is within max and min parameters
			if (distance >= min_target_distance) and (distance <= max_target_distance):
				return true
	
	return false
