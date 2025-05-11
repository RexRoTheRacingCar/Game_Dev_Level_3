############################## Game (Delete or Change Later) ##############################
extends Node2D

var enemy := preload("res://scenes/entity/enemy/test_enemy.tscn")
var explode_enemy := preload("res://scenes/entity/enemy/exploding_enemy_1.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _unhandled_input(event): #Change pause status based on "pause" pressed
	if event.is_action_pressed("spawn_enemy"):
		Global.spawn_particle(get_global_mouse_position(), $Player, explode_enemy)


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	for _h in range(0, 10000):
		await get_tree().create_timer(1.1, false).timeout
		var rand = randf_range(0.0, 1.0)
		if rand >= 0.80:
			Global.spawn_particle(Vector2(60, 30), $Player, explode_enemy)
		else:
			Global.spawn_particle(Vector2(60, 30), $Player, enemy)
