############################## Wave Portal ##############################
extends Node2D

var has_detected_player : bool = false

const GUIDING_ARROW = preload("res://scenes/misc/guiding_arrow.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	Global.connect("room_changed", queue_free)
	visible = false
	
	global_position = Global.rand_nav_mesh_point(Global.global_map, 2, false)
	
	while global_position.distance_to(Global.player_position) < 250:
		global_position = Global.rand_nav_mesh_point(Global.global_map, 2, false)
	
	visible = true
	
	#Add arrow scene that points at portal
	var arrow = GUIDING_ARROW.instantiate()
	arrow.follow_target = Global.player
	arrow.point_target = self
	arrow.modulate = Color(0, 0.8, 1.0)
	get_tree().root.get_node("/root/Game/").add_child(arrow)


#---------------------------------------------------------------------------------------------------------------------------
func _on_player_detect_body_entered(_body : Player):
	if has_detected_player == false:
		Global.emit_signal("portal_entered")
		has_detected_player = true
