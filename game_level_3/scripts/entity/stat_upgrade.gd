############################## Stat Upgrade ##############################
#@tool
extends Area2D

@export var animation_player : AnimationPlayer
@export var sprite : Sprite2D
@export var upgrade : BaseUpgrade:
	set(new_value):
		upgrade = new_value
		needs_update = true

#Used to update the sprite if updated in the editor
@export var needs_update : bool = false
var collected : bool = false
var current_scale : float = 0.0

var track_player : bool = false

#---------------------------------------------------------------------------------------------------------------------------
func _ready() -> void:
	randomize()
	
	collected = false
	sprite.texture = upgrade.texture
	$GPUParticles2D.emitting = true
	
	call_deferred("start")


#---------------------------------------------------------------------------------------------------------------------------
func start():
	animation_player.speed_scale = randf_range(0.9, 1.1)
	animation_player.queue("idle")
	
	#Misc for paritcle effects
	if upgrade.rarity == "Rare":
		$GPUParticles2D.self_modulate = Color(0.34, 1, 1, 1)
	elif upgrade.rarity == "Epic":
		$GPUParticles2D.self_modulate = Color(0.836, 0.351, 0.9, 1)
	elif upgrade.rarity == "Legendary":
		$GPUParticles2D.self_modulate = Color(0.95, 0.697, 0, 1)


#---------------------------------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	#Only runs when in the editor
	if Engine.is_editor_hint():
		if needs_update:
			sprite.texture = upgrade.texture
			needs_update = false
	
	current_scale = lerpf(current_scale, 0.5, Global.weighted_lerp(10.0, delta))
	scale = Vector2(current_scale, current_scale)
	
	if track_player == true:
		global_position = Global.player_position


#---------------------------------------------------------------------------------------------------------------------------
#When player enteres area
func _on_body_entered(body):
	if not Engine.is_editor_hint():
		#If colliding with player and isn't already collected
		if body.name == "Player" and collected == false:
			collected = true
			$GPUParticles2D.emitting = false
			
			#Apply to bullet upgrade array
			if upgrade.upgrade_type == "p_bullet_upgrades":
				body.P_WEAPON_CONTROLLER.bullet_upgrade_array.append(upgrade)
			
			#Apply directly to player
			elif upgrade.upgrade_type == "p_upgrades":
				body.p_upgrades = upgrade
			
			animation_player.stop()
			animation_player.play("collected")
