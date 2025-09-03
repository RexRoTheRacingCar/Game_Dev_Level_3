############################## Global Audio ##############################
extends Node


#---------------------------------------------------------------------------------------------------------------------------
func play_2d_sound(sound_to_play : AudioStream, AudioBus : StringName, global_position : Vector2, pitch_shift : bool):
	var new_sound = AudioStreamPlayer2D.new()
	new_sound.stream = sound_to_play
	new_sound.set_bus(AudioBus)
	new_sound.global_position = global_position
	
	if pitch_shift == true:
		new_sound.pitch_scale = 1.0 + randf_range(0.1, -0.1)
	
	get_tree().root.add_child(new_sound)
	
	new_sound.connect("finished", new_sound.queue_free)
	
	return new_sound


#---------------------------------------------------------------------------------------------------------------------------
func play_sound(sound_to_play : AudioStream, AudioBus : StringName, pitch_shift : bool):
	var new_sound = AudioStreamPlayer.new()
	new_sound.stream = sound_to_play
	new_sound.set_bus(AudioBus)
	new_sound.autoplay = true
	
	if pitch_shift == true:
		new_sound.pitch_scale = 1.0 + randf_range(0.1, -0.1)
	
	get_tree().root.add_child(new_sound)
	
	new_sound.connect("finished", new_sound.queue_free)
