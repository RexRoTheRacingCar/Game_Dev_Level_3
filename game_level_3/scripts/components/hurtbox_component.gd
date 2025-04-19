############################## Hurtbox Component ##############################
extends Area2D
class_name HurtboxComponent


signal hurtbox_hit(body : CollisionObject2D)
signal hurtbox_exited(body : CollisionObject2D)

#Variables
@export var hurt_damage : int
@export var hurt_knockback : float
@export var knockback_type : String
@export var hurt_stun : float


#---------------------------------------------------------------------------------------------------------------------------
func _on_body_entered(body):
	hurtbox_hit.emit(body)


#---------------------------------------------------------------------------------------------------------------------------
func _on_body_exited(body):
	hurtbox_exited.emit(body)
