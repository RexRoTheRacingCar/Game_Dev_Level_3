############################## Game Manager ##############################
extends Node2D

@export_group("Required")
@export var ENEMY_SCENE_LIST : RoomArray
@export var BOSS_SCENE_LIST : RoomArray
@export var ROOM_GENERATOR : RoomGenerator
@export var PLAYER : Player

@export_group("Customisable Enemies")
@export var maximum_enemies : int = 16
@export var min_time_till_arrows : float = 20.0

#Scene variables
const GUIDING_ARROW = preload("res://scenes/misc/guiding_arrow.tscn")
const SPAWN_ANIMATION = preload("res://scenes/entity/spawn_animation.tscn")

var is_generating : bool = false
var arrows_generated : bool = false
var loop_breaker : bool = false

@export_group("Customisable Waves")
@export var generate_waves : bool
@export var max_waves : int = 3


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	
	arrows_generated = false
	is_generating = false
	
	#Reset global values
	Global.active_enemy_array = []
	
	Global.connect("summon_enemies_for_boss", _spawn_wave)
	Global.connect("kill_all_enemies", _break_loop)


#---------------------------------------------------------------------------------------------------------------------------
#Generates a wave of enemies
func _generate_wave():
	Global.wave_counter += 1
	Global.wave_time = 0.0
	Global.enemy_count = 0 
	
	is_generating = true
	arrows_generated = false
	
	await get_tree().create_timer(1.0, false).timeout
	
	if loop_breaker == true: return
	
	#Wave spawn time variation
	var generating_delay = (0.9 * (randf_range(0.1, 0.95) ** 2)) + 0.25
	
	var enemy_variance = randi_range(0, ENEMY_SCENE_LIST.room_array.size() - 1)
	var enemy_array : Array = ENEMY_SCENE_LIST.room_array.duplicate()
	
	#Select random enemies from enemy array and add them to new array
	for _i in randi_range(0, enemy_variance):
		var rand_selection = randi_range(0, enemy_array.size() - 1)
		enemy_array.remove_at(rand_selection)
	
	#Spawn random enemies from new random list (Max & Min amounts found here)
	var max_possible_enemies : int = roundi(roundf((maximum_enemies + Global.rooms_cleared)) / roundf((float(Global.current_max_waves) / float(Global.wave_counter))))
	max_possible_enemies = clampi(max_possible_enemies, Global.wave_counter, max_possible_enemies)
	
	var minimum_enemies : int = Global.wave_counter + int(float(Global.rooms_cleared) / 3)
	
	for enemy in randi_range(minimum_enemies, max_possible_enemies):
		var selected_enemy = enemy_array[randi_range(0, enemy_array.size() - 1)] #Select an enemy to spawn
		var rand_postion = Global.rand_nav_mesh_point(ROOM_GENERATOR.current_room_mesh, 2, false) #Find random position
		var new_enemy = Global.spawn_particle(rand_postion, self, SPAWN_ANIMATION) #Spawn enemy
		new_enemy.enemy_scene = selected_enemy #Update spawn anim to spawn slected enemy
		
		await get_tree().create_timer(generating_delay, false).timeout #Await a small delay
		if loop_breaker == true: return
	
	await get_tree().create_timer(3.0, false).timeout
	
	is_generating = false


#Spawns a boss fight
#---------------------------------------------------------------------------------------------------------------------------
func _spawn_boss():
	Global.wave_counter += 1
	Global.wave_time = 0.0
	Global.enemy_count = 0 
	
	is_generating = true
	arrows_generated = false
	
	await get_tree().create_timer(1.5, false).timeout
	
	if loop_breaker == true: return
	
	#Spawn the boss
	var selected_boss : int = randi_range(0, BOSS_SCENE_LIST.room_array.size() - 1)
	
	var boss_spawner = SPAWN_ANIMATION.instantiate()
	boss_spawner.scale *= 2
	boss_spawner.enemy_scene = BOSS_SCENE_LIST.room_array[selected_boss]
	boss_spawner.global_position = Vector2.ZERO
	boss_spawner.spawn_speed = 0.4
	get_tree().root.get_node("/root/Game/").call_deferred("add_child", boss_spawner)
	
	await get_tree().create_timer(10.0, false).timeout
	
	is_generating = false


#---------------------------------------------------------------------------------------------------------------------------
#Creates arrows pointing to remaining enemies
func _create_arrows():
	for enemy in Global.active_enemy_array:
		var new_arrow = GUIDING_ARROW.instantiate()
		new_arrow.follow_target = PLAYER
		new_arrow.point_target = enemy
		add_child(new_arrow)


#---------------------------------------------------------------------------------------------------------------------------
func _spawn_wave():
	if is_generating == false:
		is_generating = true
		
		await get_tree().create_timer(1.0, false).timeout
		
		if loop_breaker == true: return
		
		#Wave spawn time variation
		var generating_delay = 0.75
		
		var enemy_variance = randi_range(0, ENEMY_SCENE_LIST.room_array.size() - 3)
		var enemy_array : Array = ENEMY_SCENE_LIST.room_array.duplicate()
		
		#Select random enemies from enemy array and add them to new array
		for _i in randi_range(0, enemy_variance):
			var rand_selection = randi_range(0, enemy_array.size() - 1)
			enemy_array.remove_at(rand_selection)
		
		#Spawn random enemies from new random list (Max & Min amounts found here)
		var max_possible_enemies : int = 3
		var minimum_enemies : int = 1
		
		for enemy in randi_range(minimum_enemies, max_possible_enemies):
			var selected_enemy = enemy_array[randi_range(0, enemy_array.size() - 1)] #Select an enemy to spawn
			var rand_postion = Global.rand_nav_mesh_point(ROOM_GENERATOR.current_room_mesh, 2, false) #Find random position
			var new_enemy = Global.spawn_particle(rand_postion, self, SPAWN_ANIMATION) #Spawn enemy
			new_enemy.enemy_scene = selected_enemy #Update spawn anim to spawn slected enemy
			
			await get_tree().create_timer(generating_delay, false).timeout #Await a small delay
			if loop_breaker == true: return
			
			Global.current_max_waves = 1
		
		await get_tree().create_timer(2.0, false).timeout
		
		is_generating = false


#---------------------------------------------------------------------------------------------------------------------------
func _break_loop():
	loop_breaker = true
	await get_tree().create_timer(1.0, false).timeout
	loop_breaker = false
