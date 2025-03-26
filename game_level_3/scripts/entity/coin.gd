############################## Pickup Coin ##############################
extends Area2D

var target : Player
var speed : float = 0
var velocity = Vector2.ZERO

#---------------------------------------------------------------------------------------------------------------------------
func _process(delta):
	if target:
		speed += 450 * delta
		clamp(speed, 0, 800)
		
		var dir = get_angle_to(Global.player_position)
		velocity = Vector2.RIGHT.rotated(dir) * speed
		global_position += velocity * delta


#---------------------------------------------------------------------------------------------------------------------------
func _on_collection_radius_body_entered(body : Player):
	Global.player_coins += 1
	queue_free()

#---------------------------------------------------------------------------------------------------------------------------
func _on_body_entered(body : Player):
	target = body
