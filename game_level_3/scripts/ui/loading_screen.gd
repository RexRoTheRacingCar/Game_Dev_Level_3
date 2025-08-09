############################## Loading Screen ##############################
extends CanvasLayer


@export var progress_bar : ProgressBar
var scene_name : String = ""
var progress : Array = []
var scene_load_status := 0


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	scene_name = Global.scene_to_load
	ResourceLoader.load_threaded_request(scene_name)


#---------------------------------------------------------------------------------------------------------------------------
#Loading the scene
func _process(_delta):
	scene_load_status = ResourceLoader.load_threaded_get_status(scene_name, progress)
	progress_bar.value = progress[0]
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		
		await get_tree().create_timer(0.1, false).timeout
		
		var new_scene = ResourceLoader.load_threaded_get(scene_name)
		get_tree().change_scene_to_packed(new_scene)
