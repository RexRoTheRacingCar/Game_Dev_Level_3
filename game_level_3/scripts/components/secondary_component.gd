############################## Secondary Component ##############################
extends Resource
class_name SecondaryAbility


@export var secondary_attack : PackedScene
@export var secondary_outline : AtlasTexture
@export var cooldown : float = 5.0
@export var charge_time : float = 1.0
#Locations : Player = Global.player_position, Mouse = get_global_mouse_position()
@export var spawn_location_type : int = 2

var is_usable : bool = true


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	randomize()


#---------------------------------------------------------------------------------------------------------------------------
#Instantiates a scene and adds the child to the given parent
func spawn_scene(scene : PackedScene, parent : Node):
	var new_scene = scene.instantiate()
	parent.call_deferred("add_child", new_scene)
	return new_scene


#---------------------------------------------------------------------------------------------------------------------------
func rand_vector(min_value : float, max_value : float) -> Vector2:
	return Vector2(
		randf_range(min_value, max_value),
		randf_range(min_value, max_value)
	)
