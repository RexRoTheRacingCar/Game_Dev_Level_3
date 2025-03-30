############################## Test Enemy ##############################
extends CharacterBody2D

#A test enemy to figure out how I'm going to implement enemies

#Node variables
@export var hitbox_component : HitboxComponent
@export var hurtbox_component : HurtboxComponent
@export var health_component : HealthComponent
@export var line_of_sight : TargetRaycast


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
	Global.spawn_coins(10, global_position, self)
	queue_free()


#---------------------------------------------------------------------------------------------------------------------------
func _process(_delta: float) -> void:
	#If Line of Sight returns true
	if line_of_sight.target_check((Global.player_position - global_position), global_position) == true:
		var player_pos := Global.player_position - global_position
		player_pos.y *= 2
		
		var dir = player_pos.angle()
		
		velocity = Vector2.RIGHT.rotated(dir) * 225
		velocity.y /= 2
		move_and_slide()
