############################## Exploding Enemy 1 ##############################
extends Entity

enum {
	PURSUIT,
	DIVING
}
var state := PURSUIT

var explode_time : float = 0.0
var detected : bool = false
var exploded : bool = false

var dir_1 : float = 0.0
var dir_2 : float = 0.0
var player_angle_pos : Vector2

@export var speed : float = 425.0
var explode_scene := preload("res://scenes/entity/secondaries/test_secondary.tscn")

@onready var sprite = $Sprite2D


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	super._ready()
	
	state = PURSUIT
	explode_time = 0.0
	detected = false
	exploded = false


#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta) -> void:
	#If Area Of Sight returns with a target
	if area_of_sight.target != null:
		_navigation_check(Global.player_position, 0.35, 0.7)
		
		match state: #Exploding enemy code based state machine
			PURSUIT:
				los_check = line_of_sight.target_check(Global.player_position - global_position, global_position)
				
				if can_navigate == true:
					#Navigate to player
					velocity = lerp(Vector2(
						velocity.x, velocity.y * 2), 
						current_agent_position.direction_to(next_path_position) * speed, 0.1
						)
			
			DIVING:
				#Dive in front of player
				velocity = Vector2.RIGHT.rotated(dir_1) * speed
				speed = lerp(speed, 0.0, 0.05)
				
				explode_time += delta
				if explode_time > 0.6 and exploded == false:
					exploded = true
					no_health()
		
		
		#Apply velocity
		velocity.y /= 2
		velocity += knockback_taken
		move_and_slide()


#---------------------------------------------------------------------------------------------------------------------------
func no_health():
	super.no_health()
	set_physics_process(false)
	visible = false
	
	#Disable all collision
	set_collision_layer_value(1, false)
	set_collision_layer_value(4, false)
	set_collision_mask_value(5, false)
	
	#Create explosion when leaving the scene (on death)
	_instantiate_explosion(0, 0, 4)
	for i in range(1, 3):
		await get_tree().create_timer(0.25, false).timeout
		
		for d in range(0, 4): 
			_instantiate_explosion(i, d, 4) 
	queue_free()


#---------------------------------------------------------------------------------------------------------------------------
func _instantiate_explosion(i, d, am):
	var new_explosion = explode_scene.instantiate()
	
	#Update explosion values
	new_explosion.visible = true
	var explode_dir = (((2 * PI) / am) * d) + dir_1
	var postion_correction = (Vector2.RIGHT.rotated(explode_dir) * 180 * i)
	new_explosion.global_position = global_position + Vector2(postion_correction.x, postion_correction.y / 2)
	new_explosion.rotation = 0
	new_explosion.scale = Vector2(1.2, 1.2)
	
	get_tree().root.get_node("/root/Game/").call_deferred("add_child", new_explosion)
	
	#Allow explosion to hurt player
	new_explosion.get_node("HurtboxComponent").call_deferred("set_collision_layer_value", 2, true)


#---------------------------------------------------------------------------------------------------------------------------
func _on_dive_detection_body_entered(body):
	if body is Player and detected == false and los_check == true:
		detected = true
		
		#Tween speed to 0 
		#Speed Tween
		var TWEEN_TIME := 0.4
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT).set_parallel(true)
		tween.tween_property(self, "speed", 0, TWEEN_TIME).from_current()
		
		await get_tree().create_timer(TWEEN_TIME + 0.05, false).timeout
		
		if state == DIVING:
			return
		
		#Get direction towards player
		player_angle_pos = Global.player_position
		dir_1 = get_angle_to(Vector2(player_angle_pos.x, (player_angle_pos.y * 2) - global_position.y))
		state = DIVING
		
		#Tween dive speed
		var dive_tween = create_tween()
		dive_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		dive_tween.tween_property(self, "speed", 1000.0, 0.3).from(0.0)
		
		#Jump Tween
		var jump_tween = create_tween()
		jump_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_parallel(false)
		jump_tween.tween_property(sprite, "position", Vector2(0, -20), 0.4).from_current()
		jump_tween.tween_property(sprite, "position", Vector2(0, 0), 0.4).from_current().set_ease(Tween.EASE_IN)
		
		#Flash animation
		for _amount in range(0, 4):
			hit_flash_anim.play("hit_flash")
			await get_tree().create_timer(0.25, false).timeout
