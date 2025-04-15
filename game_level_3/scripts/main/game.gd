############################## Game Setting (Delete or Change Later) ##############################
extends Node2D


var enemy := preload("res://scenes/entity/enemy/test_enemy.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _unhandled_input(event): #Change pause status based on "pause" pressed
	if event.is_action_pressed("spawn_enemy"):
		Global.spawn_particle(get_global_mouse_position(), $Player, enemy)


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	for _h in range(0, 10000):
		await get_tree().create_timer(1.1, false).timeout
		Global.spawn_particle(Vector2(60, 30), $Player, enemy)
