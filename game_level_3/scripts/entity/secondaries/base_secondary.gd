############################## Secondary Base ##############################
extends CharacterBody2D
class_name BaseSecondary

@export var default_power : float = 1.0
@export var power_mult : float = 1.0
var power : float = 0.0

@export var anim_player : AnimationPlayer
@export var particle_nodes : Array = []
@export var vis_node : VisibleOnScreenNotifier2D

#---------------------------------------------------------------------------------------------------------------------------
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
	power = default_power * PlayerUpgradeStats.power_mult
