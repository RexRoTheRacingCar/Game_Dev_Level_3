############################## Delete if not seen ##############################
extends VisibleOnScreenNotifier2D

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	self.connect("screen_exited", _on_screen_exited)
	

	if call_deferred("is_on_screen") == false:
		get_parent().queue_free()

#---------------------------------------------------------------------------------------------------------------------------
func _on_screen_exited():
	get_parent().queue_free()
