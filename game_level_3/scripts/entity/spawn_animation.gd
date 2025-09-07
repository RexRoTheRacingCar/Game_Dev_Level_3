############################## Spawn Animation ##############################
extends Node2D


@warning_ignore("unused_private_class_variable")
@onready var anim_player = $AnimationPlayer
var spawn_speed : float = 1.0
var enemy_scene : PackedScene

const ENEMY_SPAWNED_SFX = preload("res://assets/audio/diegetic_sfx/enemies/enemy_spawned.mp3")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	Global.connect("reset_to_lobby", queue_free)
	Global.connect("kill_all_enemies", queue_free)
	
	anim_player.speed_scale = spawn_speed


#---------------------------------------------------------------------------------------------------------------------------
func _spawn_enemy():
	var new_enemy = enemy_scene.instantiate()
	
	new_enemy.visible = true
	new_enemy.global_position = global_position
	new_enemy.scale = Vector2(1, 1)
	
	get_tree().root.get_node("/root/Game/").call_deferred("add_child", new_enemy)
	
	AudioManager.play_2d_sound(ENEMY_SPAWNED_SFX, "SFX", global_position, true)
