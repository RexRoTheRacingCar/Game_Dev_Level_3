############################## Game Setting (Delete or Change Later) ##############################
extends Node2D


var enemy := preload("res://scenes/entity/enemy/test_enemy.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _unhandled_input(event): #Change pause status based on "pause" pressed
	if event.is_action_pressed("spawn_enemy"):
		Global.spawn_particle(Vector2(-300, 300), $Player, enemy)
