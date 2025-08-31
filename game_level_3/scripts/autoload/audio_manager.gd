############################## Global Audio ##############################
extends Node

const PLAY_AUDIO_2D = preload("res://scenes/components/audio_play_2d.tscn")

#---------------------------------------------------------------------------------------------------------------------------
func play_2d_sound(sound_to_play : AudioStream, AudioBus : StringName, global_position : Vector2):
	var new_sound = PLAY_AUDIO_2D.instantiate()
	new_sound.stream = sound_to_play
	new_sound.set_bus(AudioBus)
	new_sound.global_position = global_position
	
	get_tree().root.add_child(new_sound)
	
	return new_sound


#---------------------------------------------------------------------------------------------------------------------------
func play_sound(sound_to_play : AudioStream, AudioBus : StringName):
	var new_sound = AudioStreamPlayer.new()
	new_sound.stream = sound_to_play
	new_sound.set_bus(AudioBus)
	new_sound.autoplay = true
	
	get_tree().root.add_child(new_sound)
	
	new_sound.connect("finished", new_sound.queue_free)
