############################## Portal Base Class ##############################
extends Node2D
class_name PortalBase

var target_alpha : float = 1.0
var current_alpha : float = 0.0

@export var HITBOX : Area2D
var has_detected_player : bool = false

const GUIDING_ARROW = preload("res://scenes/misc/guiding_arrow.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _process(delta):
	current_alpha = lerpf(current_alpha, target_alpha, Global.weighted_lerp(5, delta))
	modulate = Color(1.0, 1.0, 1.0, current_alpha)


#---------------------------------------------------------------------------------------------------------------------------
func _portal_prep():
	Global.connect("room_changed", queue_free)
	Global.connect("portal_entered", _other_portal_entered)
	
	current_alpha = 0.0
	target_alpha = 1.0
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	
	set_process(true)
	
	#Add arrow scene that points at portal
	var arrow = GUIDING_ARROW.instantiate()
	arrow.follow_target = Global.player
	arrow.point_target = self
	arrow.modulate = Color(0, 0.8, 1.0)
	get_tree().root.get_node("/root/Game/").add_child(arrow)
	
	HITBOX.monitoring = false
	HITBOX.monitorable = false
	
	await get_tree().create_timer(2.0, false).timeout
	
	HITBOX.monitoring = true


#---------------------------------------------------------------------------------------------------------------------------
func _find_rand_position():
	visible = false
	
	global_position = Global.rand_nav_mesh_point(Global.global_map, 2, false)
	
	while global_position.distance_to(Global.player_position) < 250:
		global_position = Global.rand_nav_mesh_point(Global.global_map, 2, false)
	
	visible = true


#---------------------------------------------------------------------------------------------------------------------------
func _on_player_detect_body_entered(_body : Player):
	if has_detected_player == false:
		has_detected_player = true
		target_alpha = 0.0
		Global.emit_signal("portal_entered")


#---------------------------------------------------------------------------------------------------------------------------
func _other_portal_entered():
	if has_detected_player == false:
		has_detected_player = true
		target_alpha = 0.0
