############################## Spawn Animation ##############################
extends Node2D

var enemy_scene : PackedScene

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	Global.connect("reset_to_lobby", queue_free)


#---------------------------------------------------------------------------------------------------------------------------
func _spawn_enemy():
	var new_enemy = enemy_scene.instantiate()
	
	new_enemy.visible = true
	new_enemy.global_position = global_position
	
	get_tree().root.get_node("/root/Game/").call_deferred("add_child", new_enemy)
	
