############################## Area Of Sight ##############################
extends Area2D
class_name AreaOfSight


@export var radius : float = 25.0
@onready var collision_shape_2d = $CollisionShape2D

var target : Node2D = null

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	collision_shape_2d.shape.radius = radius
	collision_shape_2d.scale.y = 0.5


#---------------------------------------------------------------------------------------------------------------------------
func _on_area_entered(area : Area2D):
	if area.name == "EnemyHitbox":
		target = area

func _on_area_exited(area : Area2D):
	if area.name == "EnemyHitbox":
		target = null
