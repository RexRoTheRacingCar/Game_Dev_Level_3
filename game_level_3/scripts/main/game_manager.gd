############################## Game Manager ##############################
extends Node2D

@export_group("Required")
@export var ENEMY_SCENE_LIST : RoomArray
@export var ROOM_GENERATOR : RoomGenerator
@export var PLAYER : Player

@export_group("Customisable")
@export var minimum_enemies : int = 1
@export var maximum_enemies : int = 16
@export var time_till_arrows : float = 24.0

#Scene variables
const GUIDING_ARROW = preload("res://scenes/misc/guiding_arrow.tscn")
const SPAWN_ANIMATION = preload("res://scenes/entity/spawn_animation.tscn")

var is_generating : bool = false
var arrows_generated : bool = false

@export var generate_waves : bool


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	set_process(false)
	
	arrows_generated = false
	is_generating = false
	
	#Reset global values
	Global.enemy_count = 0 
	Global.enemy_wave = false
	Global.active_enemy_array = []
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	if generate_waves == true:
		call_deferred("_generate_wave")
		set_process(true)


#---------------------------------------------------------------------------------------------------------------------------
func _process(delta):
	Global.wave_time += delta
	if Global.enemy_count == 0 and is_generating == false:
		Global.enemy_wave = false
		if Global.enemy_wave == false:
			_generate_wave()
	
	if Global.enemy_count > 0 and Global.wave_time > time_till_arrows and arrows_generated == false:
		arrows_generated = true
		_create_arrows()


#---------------------------------------------------------------------------------------------------------------------------
#Generates a wave of enemies
func _generate_wave():
	Global.enemy_wave = true
	Global.wave_time = 0
	
	is_generating = true
	arrows_generated = false
	
	await get_tree().create_timer(1.0, false).timeout
	
	var generating_delay = (randf_range(0.1, 1.0) ** 6) + 0.1
	
	var enemy_variance = randi_range(0, ENEMY_SCENE_LIST.room_array.size() - 1)
	var enemy_array : Array = []
	
	enemy_array.append_array(ENEMY_SCENE_LIST.room_array)
	
	#Select random enemies from enemy array and add them to new array
	for _i in randi_range(0, enemy_variance):
		var rand_selection = randi_range(0, enemy_array.size() - 1)
		enemy_array.erase(enemy_array[rand_selection])
	
	#Spawn random enemies from new random list
	for i in randi_range(minimum_enemies, maximum_enemies):
		var selected_enemy = enemy_array[randi_range(0, enemy_array.size() - 1)] #Select an enemy to spawn
		var rand_postion = Global.rand_nav_mesh_point(ROOM_GENERATOR.current_room_mesh, 2, false) #Find random position
		var new_enemy = Global.spawn_particle(rand_postion, self, SPAWN_ANIMATION) #Spawn enemy
		new_enemy.enemy_scene = selected_enemy #Update spawn anim to spawn slected enemy
		
		await get_tree().create_timer(generating_delay, false).timeout #Await a small delay
	
	await get_tree().create_timer(2.5, false).timeout
	
	is_generating = false


#---------------------------------------------------------------------------------------------------------------------------
#Creates arrows pointing to remaining enemies
func _create_arrows():
	for enemy in Global.active_enemy_array:
		var new_arrow = GUIDING_ARROW.instantiate()
		new_arrow.follow_target = PLAYER
		new_arrow.point_target = enemy
		add_child(new_arrow)
