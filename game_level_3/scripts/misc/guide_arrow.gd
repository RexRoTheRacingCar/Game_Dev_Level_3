############################## Guiding Arrow ##############################
extends Sprite2D

@export var point_target : Node2D
@export var follow_target : Node2D

#Distance from following node
@export var distance_from_follow : float = 70.0
@export var fade_distance : float = 250.0

var alpha : float = 0.0
var target_alpha : float = 0.0


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	
	alpha = 0.0
	target_alpha = 0.0
	
	self_modulate = Color(0.425, 0.425, 0.425, alpha)
	
	Global.connect("room_changed", queue_free)
	Global.connect("reset_to_lobby", queue_free)


#---------------------------------------------------------------------------------------------------------------------------
func _process(_delta):
	if is_instance_valid(follow_target) and is_instance_valid(point_target):
		position = follow_target.global_position
		look_at(point_target.global_position)
		#Global position based on normalized vector (from postion difference to target position)
		global_position = (global_position - point_target.global_position).normalized() * -distance_from_follow + global_position
		
		#Set arrow alpha based on distance from target
		target_alpha = (global_position.distance_to(point_target.global_position) - 500) / fade_distance
		alpha = clamp(lerpf(alpha, target_alpha, 0.05), 0.0, 0.8)
		self_modulate = Color(0.425, 0.425, 0.425, alpha)
	else:
		queue_free()
