############################## Test Enemy ##############################
extends CharacterBody2D

#A test enemy to figure out how I'm going to implement enemies

#Node variables
@export var hitbox_component : HitboxComponent
@export var hurtbox_component : HurtboxComponent
@export var health_component : HealthComponent
@export var area_of_sight : AreaOfSight

@onready var navigation_agent_2d = $NavigationAgent2D

#Number Variables
@export var coin_range : int


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	coin_range = randi_range(8, 12)
	
	#Connect enemy to signals
	hitbox_component.hitbox_entered.connect(hit_signalled)
	health_component.zero_health.connect(no_health)


#---------------------------------------------------------------------------------------------------------------------------
func _process(_delta: float) -> void:
	#If Area Of Sight returns with a target
	if area_of_sight.target != null:
		navigation_agent_2d.target_position = Global.player_position
		if navigation_agent_2d.is_navigation_finished():
			return
		
		#Navigate to player
		var current_agent_position = global_position
		var next_path_position = navigation_agent_2d.get_next_path_position()
		
		#Apply velocity towards navigation path
		velocity = current_agent_position.direction_to(next_path_position) * 225
		velocity.y /= 2
		
		move_and_slide()

#---------------------------------------------------------------------------------------------------------------------------
#Enemy hit
func hit_signalled(hurtbox: HurtboxComponent):
	health_component.health -= hurtbox.hurt_damage
	hitbox_component.hit_timer.start(hitbox_component.hit_delay)


#---------------------------------------------------------------------------------------------------------------------------
#Enemy has 0 HP
func no_health():
	Global.spawn_coins(coin_range, global_position, self)
	queue_free()
