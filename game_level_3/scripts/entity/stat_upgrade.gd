############################## Stat Upgrade ##############################
@tool
extends Area2D

@export var animation_player : AnimationPlayer
@export var sprite : Sprite2D
@export var upgrade : BaseUpgrade:
	set(new_value):
		upgrade = new_value
		needs_update = true

#Used to update the sprite if updated in the editor
@export var needs_update : bool = false

#---------------------------------------------------------------------------------------------------------------------------
func _ready() -> void:
	randomize()
	sprite.texture = upgrade.texture
	
	animation_player.speed_scale = randf_range(0.9, 1.1)
	animation_player.play("idle")


#---------------------------------------------------------------------------------------------------------------------------
func _process(_delta: float) -> void:
	#Only runs when in the editor
	if Engine.is_editor_hint():
		if needs_update:
			sprite.texture = upgrade.texture
			needs_update = false


#---------------------------------------------------------------------------------------------------------------------------
#When player entered area
func _on_body_entered(body):
	if not Engine.is_editor_hint():
		if body.name == "Player":
			#Apply to bullet upgrade array
			if upgrade.upgrade_type == "p_bullet_upgrades":
				body.p_bullet_upgrades.append(upgrade)
			
			#Apply directly to player
			elif upgrade.upgrade_type == "p_upgrades":
				body.p_upgrades = upgrade
			
			animation_player.stop()
			animation_player.play("collected")
