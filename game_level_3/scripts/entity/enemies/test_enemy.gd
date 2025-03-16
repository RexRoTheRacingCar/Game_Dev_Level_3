############################## Test Enemy ##############################
extends CharacterBody2D

#A test enemy to figure out how I'm going to implement enemies
@export var hitbox_component : HitboxComponent
@export var hurtbox_component : HurtboxComponent
@export var health_component : HealthComponent

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	#Connect enemy to signals
	hitbox_component.hitbox_entered.connect(hit_signalled)
	health_component.zero_health.connect(no_health)


#---------------------------------------------------------------------------------------------------------------------------
#Enemy hit
func hit_signalled(hurtbox: HurtboxComponent):
	health_component.health -= hurtbox.hurt_damage
	hitbox_component.hit_timer.start(hitbox_component.hit_delay)


#---------------------------------------------------------------------------------------------------------------------------
#Enemy has 0 HP
func no_health():
	queue_free()
