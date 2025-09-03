############################## Secondary Base ##############################
extends CharacterBody2D
class_name BaseSecondary

@export var default_power : float = 1.0
@export var power_mult : float = 1.0
var power : float = 0.0

var player_made : bool = false

@export var anim_player : AnimationPlayer
@export var particle_nodes : Array = []
@export var vis_node : VisibleOnScreenNotifier2D

#---------------------------------------------------------------------------------------------------------------------------
#Check if all particle nodes can emit particles based on settings
func _particle_check(): 
	if particle_nodes.is_empty() == false:
		if GlobalSettings.limited_particles == true:
			for emitter in particle_nodes.size():
				particle_nodes[emitter].amount = round(particle_nodes[emitter].amount / 1.75)
		
		if vis_node:
			if vis_node.call_deferred("is_on_screen") == false:
				for emitter in particle_nodes.size():
					particle_nodes[emitter].amount = 1
					particle_nodes[emitter].visible = false


#---------------------------------------------------------------------------------------------------------------------------
func _apply_mult():
	Global.connect("room_changed", queue_free)
	Global.connect("reset_to_lobby", queue_free)
	
	power = default_power
	if player_made == true:
		power *= PlayerUpgradeStats.power_mult
