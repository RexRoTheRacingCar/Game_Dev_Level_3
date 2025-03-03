############################## Player ##############################
extends CharacterBody2D
class_name Player


#Node variables
@export_group("Nodes")
@export var p_dash_timer : Timer

#Movement variables
@export_group("Customisable")
@export var p_speed : float = 425
@export var P_ACCEL : int = 3000
@export var P_FRICTION : int = 20000
var p_vel_prep : Vector2
var p_dashing : bool = false

#Misc variables
@export var p_dash_delay : float = 0.9


#---------------------------------------------------------------------------------------------------------------------------
func _ready():
	#Variable prep
	p_dashing = false
	p_vel_prep = Vector2.ZERO
	velocity = Vector2.ZERO


#---------------------------------------------------------------------------------------------------------------------------
#THE MAIN PHYSICS PROCESS
#---------------------------------------------------------------------------------------------------------------------------
func _physics_process(delta):
	#Player movement
	var p_input = Input.get_vector("left", "right", "up", "down") #Get movement vector
	player_movement(p_input, delta)
	
	#Player roll
	if Input.is_action_just_pressed("dash"):
		player_dash(p_input)
	
	#Apply motion
	velocity = Vector2(p_vel_prep.x, p_vel_prep.y / 2)
	var _error = move_and_slide()


#---------------------------------------------------------------------------------------------------------------------------
#Player Movement Function
func player_movement(p_input, delta):
	#If moving
	if p_input: 
		p_vel_prep = p_vel_prep.move_toward(p_input * p_speed , delta * P_ACCEL)
	
	#If not moving
	else: 
		p_vel_prep = p_vel_prep.move_toward(Vector2(0,0), delta * P_FRICTION)
		
	


#---------------------------------------------------------------------------------------------------------------------------
#Player Dash Function
func player_dash(p_input):
	if p_dashing == false and p_input:
		p_dashing = true
		
		p_vel_prep = p_input * 2200
		
		p_dash_timer.start(p_dash_delay)



#---------------------------------------------------------------------------------------------------------------------------
#Player dash timer signal
func _on_dash_timer_timeout():
	if p_dashing == true:
		p_dashing = false
