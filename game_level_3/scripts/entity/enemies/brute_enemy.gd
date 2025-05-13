############################## Brute Enemy ##############################
extends Entity

@export var DEFAULT_SPEED : float = 175.0
@export var CHARGE_SPEED : float = 600.0
var speed : float = 150.0

@export var CHARGE_TIME : float = 1.6
var is_charging : bool = true


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	super._ready()
	is_charging = true
	
	speed = DEFAULT_SPEED


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(_delta: float) -> void:
	#If Area Of Sight returns with a target
	if area_of_sight.target != null:
		if is_charging == true:
			_navigation_check(Global.player_position, 0.35, 0.65)
			print("Navigating ", is_charging)
			
		elif is_charging == false:
			print("Charging ", is_charging)
			can_navigate = true
		
		if can_navigate == true:
			#Navigate to player
			velocity = lerp(Vector2(
				velocity.x, velocity.y * 2), 
				current_agent_position.direction_to(next_path_position) * speed, 0.8
				)
			
			velocity.y /= 2
			velocity += knockback_taken
			
			move_and_slide()


#---------------------------------------------------------------------------------------------------------------------------
func no_health():
	super.no_health()
	queue_free()


#---------------------------------------------------------------------------------------------------------------------------
func _on_charge_detection_body_entered(body: Node2D) -> void:
	if body is Player and is_charging == true:
		speed = 0
		
		_navigation_check(Global.player_position, 0.35, 0.65)
		
		await get_tree().physics_frame
		
		is_charging = false
		hurtbox_component.set_collision_layer_value(4, true)
		
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "speed", CHARGE_SPEED, CHARGE_TIME / 2).from_current()
		
		await get_tree().create_timer(CHARGE_TIME + 0.05, false).timeout
		
		hurtbox_component.set_collision_layer_value(4, false)
		is_charging = true
		speed = DEFAULT_SPEED
