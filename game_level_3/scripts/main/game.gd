############################## Game (Delete or Change Later) ##############################
extends Node2D

var enemy := preload("res://scenes/entity/enemy/test_enemy.tscn")
var explode_enemy := preload("res://scenes/entity/enemy/exploding_enemy_1.tscn")
var brute_enemy := preload("res://scenes/entity/enemy/brute_enemy.tscn")

@onready var room_generator : RoomGenerator = $RoomGenerator

#---------------------------------------------------------------------------------------------------------------------------
func _unhandled_input(event): #Change pause status based on "pause" pressed
	if event.is_action_pressed("spawn_enemy"):
		room_generator.generate_room()


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	Global.player_dead = false
	room_generator.generate_room()
	
	for _h in range(0, 10000):
		await get_tree().create_timer(1.4, false).timeout
		var rand = randf_range(0.0, 1.0)
		if rand >= 0.80:
			Global.spawn_particle(Vector2(60, 30), $Player, explode_enemy)
		elif rand >= 0.60:
			Global.spawn_particle(Vector2(60, 30), $Player, brute_enemy)
		else:
			Global.spawn_particle(Vector2(60, 30), $Player, enemy)


#---------------------------------------------------------------------------------------------------------------------------
func _process(_delta):
	if Global.player_dead == true:
		var _reload = get_tree().reload_current_scene()
		Global.player_dead = false
