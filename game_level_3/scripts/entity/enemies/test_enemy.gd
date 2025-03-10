############################## Test Enemy ##############################
extends CharacterBody2D

#A test enemy to figure out how I'm going to implement enemies
@export var hitbox_component : HitboxComponent
@export var hurtbox_component : HurtboxComponent
@export var health_component : HealthComponent


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	hitbox_component.hitbox_entered.connect(hit_signalled)


#---------------------------------------------------------------------------------------------------------------------------
#Test Enemy Hit
func hit_signalled(hurtbox: HurtboxComponent):
	health_component.health -= hurtbox.hurt_damage
	
	hitbox_component.is_hit = true
	hitbox_component.hit_timer.start(hitbox_component.hit_delay)
