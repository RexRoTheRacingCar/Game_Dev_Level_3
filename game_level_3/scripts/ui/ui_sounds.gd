############################## UI Sounds Manager ##############################
extends Node

@export var root_path : NodePath

@export var sounds = {
	&"ui_click" : AudioStreamPlayer.new(), 
	&"ui_hover" : AudioStreamPlayer.new()
}

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	for i in sounds.keys():
		sounds[i].stream = load("res://assets/audio/non_diegetic_sfx/" + str(i) + ".mp3")
		sounds[i].bus = &"SFX"
		add_child(sounds[i])
	
	install_sounds()


#---------------------------------------------------------------------------------------------------------------------------
func install_sounds():
	for i in get_tree().get_nodes_in_group("UI"):
		if i is Button:
			i.mouse_entered.connect( func(): ui_sfx_play(&"ui_hover"))
			i.pressed.connect( func(): ui_sfx_play(&"ui_click"))
		elif i is ProgressBar:
			i.value_changed.connect( func(): ui_sfx_play(&"ui_click"))


#---------------------------------------------------------------------------------------------------------------------------
func ui_sfx_play(sound : StringName) -> void:
	sounds[sound].play()
