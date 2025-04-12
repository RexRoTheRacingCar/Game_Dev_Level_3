############################## Pickup Coin ##############################
extends Area2D

var target : Player
var target_hit : bool = false
var speed : float = 0
var velocity := Vector2.ZERO
var random_offset : float

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var particles = $GPUParticles2D

#---------------------------------------------------------------------------------------------------------------------------
func _ready() -> void:
	#Setup coin at spawn
	target_hit = false
	sprite.visible = true
	particles.emitting = true
	
	randomize()
	random_offset = randf_range(0.5, 2.0)
	
	#Play coin spawn animation
	animation_player.speed_scale = random_offset
	animation_player.play("spawn")
	animation_player.queue("RESET")


#---------------------------------------------------------------------------------------------------------------------------
func _process(delta):
	#If player enters radius, speed up in direction of player until collected
	if target and target_hit == false:
		speed += 450 * delta * random_offset
		speed = clamp(speed, 0, 600)
		
		var dir = get_angle_to(Global.player_position)
		velocity = Vector2.RIGHT.rotated(dir) * speed
		global_position += velocity * delta
		if animation_player.is_playing() == false: 
			sprite.rotation_degrees += (speed * delta) / 2


#---------------------------------------------------------------------------------------------------------------------------
func _on_collection_radius_body_entered(_body : Player):
	Global.player_coins += 1
	
	target_hit = true
	sprite.visible = false
	particles.emitting = false
	
	await get_tree().create_timer(0.75, false).timeout
	
	queue_free()


#---------------------------------------------------------------------------------------------------------------------------
func _on_body_entered(body : Player):
	target = body
