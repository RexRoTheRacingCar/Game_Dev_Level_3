############################## Player ##############################
extends CharacterBody2D
class_name Player

#Movement variables
@export_group("Customisable")
@export var p_speed : float = 425
const P_ACCEL : int = 3000
const P_FRICTION : int = 20000
var p_vel_prep : Vector2

#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	p_vel_prep = Vector2.ZERO
	velocity = Vector2.ZERO


#THE MAIN PHYSICS PROCESS
#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta):
	#Player Movement
	var p_input = Input.get_vector("left", "right", "up", "down") #Get movement vector
	player_movement(p_input, delta)
	
	var _error = move_and_slide()


#Player Movement Function
#---------------------------------------------------------------------------------------------------------------------------
func player_movement(p_input, delta):
	#If moving
	if p_input: 
		p_vel_prep = p_vel_prep.move_toward(p_input * p_speed , delta * P_ACCEL)
	
	#If not moving
	else: 
		p_vel_prep = p_vel_prep.move_toward(Vector2(0,0), delta * P_FRICTION)
		
	velocity = Vector2(p_vel_prep.x, p_vel_prep.y / 2)
	
