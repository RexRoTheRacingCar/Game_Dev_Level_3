############################## Hurtbox Component ##############################
extends Area2D
class_name HurtboxComponent


signal hurtbox_hit(body : CollisionObject2D)

#Variables
@export var hurt_damage : int
@export var hurt_knockback : float
@export var hurt_stun : float


#---------------------------------------------------------------------------------------------------------------------------
func _on_body_entered(body: CollisionObject2D):
	hurtbox_hit.emit(body)
