############################## Game (Delete or Change Later) ##############################
extends Node2D

const ENEMY := preload("res://scenes/entity/enemy/test_enemy.tscn")
const EXPLODE_ENEMY := preload("res://scenes/entity/enemy/exploding_enemy_1.tscn")
const BRUTE_ENEMY := preload("res://scenes/entity/enemy/brute_enemy.tscn")

const SPAWN_ANIMATION = preload("res://scenes/entity/spawn_animation.tscn")

@onready var room_generator : RoomGenerator = $RoomGenerator
@onready var player = $Player

#---------------------------------------------------------------------------------------------------------------------------
func _unhandled_input(event): #Change pause status based on "pause" pressed
	if event.is_action_pressed("spawn_enemy"):
		room_generator.generate_room()


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	Global.player_dead = false
	room_generator.generate_room()
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	player.position = NavigationServer2D.map_get_random_point(room_generator.current_room_mesh, 2, false)
	
	for _h in range(0, 10000):
		await get_tree().create_timer(1.4, false).timeout
		var rand = randf_range(0.0, 1.0)
		
		var nav_map = room_generator.current_room_mesh
		var rand_postion = NavigationServer2D.map_get_random_point(nav_map, 2, false)
		
		var enemy_type
		if rand >= 0.80:
			enemy_type = EXPLODE_ENEMY
		elif rand >= 0.60:
			enemy_type = BRUTE_ENEMY
		else:
			enemy_type = ENEMY
		
		var spawn_anim = Global.spawn_particle(rand_postion, $Player, SPAWN_ANIMATION)
		spawn_anim.enemy_scene = enemy_type


#---------------------------------------------------------------------------------------------------------------------------
func _process(_delta):
	if Global.player_dead == true:
		var _reload = get_tree().reload_current_scene()
		Global.player_dead = false
