############################## Test Enemy ##############################
extends CharacterBody2D

#A test enemy to figure out how I'm going to implement enemies

#Node variables
@export var hitbox_component : HitboxComponent
@export var hurtbox_component : HurtboxComponent
@export var health_component : HealthComponent
@export var area_of_sight : AreaOfSight

@onready var navigation_agent_2d = $NavigationAgent2D
@onready var nav_timer = $NavigationTimer

var timing : bool = false
var current_agent_position : Vector2
var next_path_position
var coin_range : int
var knockback_taken := Vector2.ZERO


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	coin_range = randi_range(3, 6)
	
	timing = false
	current_agent_position = global_position
	next_path_position = navigation_agent_2d.get_next_path_position()
	navigation_agent_2d.target_position = Global.player_position
	
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
		
		#Update navigation on timer
		if timing == false:
			current_agent_position = global_position
			next_path_position = navigation_agent_2d.get_next_path_position()
			
			timing = true
			nav_timer.start(randf_range(0.25, 0.65))
		
		else:
			#Navigate to player
			velocity = lerp(Vector2(velocity.x, velocity.y * 2) , current_agent_position.direction_to(next_path_position) * 250, 0.15)
			velocity.y /= 2
			
			velocity += knockback_taken
			
			move_and_slide()

#---------------------------------------------------------------------------------------------------------------------------
#Enemy hit
func hit_signalled(hurtbox: HurtboxComponent):
	health_component.health -= hurtbox.hurt_damage
	hitbox_component.hit_timer.start(hitbox_component.hit_delay)
	
	knockback_taken = hurtbox.get_parent().velocity.normalized()
	knockback_taken *= hurtbox.hurt_knockback
	
	var knockback_tweem := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	knockback_tweem.tween_property(self, "knockback_taken", Vector2.ZERO, 0.4)
	knockback_tweem.play()


#---------------------------------------------------------------------------------------------------------------------------
#Enemy has 0 HP
func no_health():
	Global.spawn_coins(coin_range, global_position, self)
	queue_free()


#---------------------------------------------------------------------------------------------------------------------------
func _on_navigation_timer_timeout():
	timing = false
