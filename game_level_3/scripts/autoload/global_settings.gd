############################## Global Settings ##############################
extends Node

#Changed by other scripts to update all settings variables
var is_updated : bool = true :
	set(new_value):
		is_updated = new_value

#Window
@export var screen_resolution : int = 0
@export var fullscreen : bool = true

#Grahpics
@export var limited_particles : bool = false
@export var show_stopwatch : bool = false
@export var show_health_bars : bool = true
@export var screenshake_multiplier : float = 1.0

#Audio
