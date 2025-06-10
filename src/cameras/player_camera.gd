extends Node3D

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## PlayerCamera
## 
## Defines a 1st person and 3rd person camera that the player can use
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

@onready var _head := $".".get_parent()
@onready var _pivot := $"."
@onready var _spring_arm := $SpringArm3D
@onready var _camera := $SpringArm3D/Camera3D

const _FIRST_PERSON_CAMERA_POSITION_OFFSET: Vector3 = Vector3(0.0, 0.0, 0.0) ## Position Offset used when the camera is in 1st-person mode
const _FIRST_PERSON_CAMERA_ROTATION_OFFSET: Vector3 = Vector3(0.0, 0.0, 0.0) ## Rotation Offset used when the camera is in 1st-person mode

const _THIRD_PERSON_CAMERA_POSITION_OFFSET: Vector3 = Vector3(0.56, 0.786, 2.068) ## Position Offset used when the camera is in 3rd-person mode
const _THIRD_PERSON_CAMERA_ROTATION_OFFSET: Vector3 = Vector3(-1.6, 3.6, -0.1) ## Rotation Offset used when the camera is in 3rd-person mode

var _character_body: CharacterBody3D

# TODO: May wanna change these two variables to const? idk if i will need to change em later yet
var max_camera_up_angle := 74.0 ## Maximum angle you can look upwards
var max_camera_down_angle := -82.0 ## Maximum angle you can look downwards

var is_first_person := true

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

# TESTING
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
# TESTING

## Allow player to control camera
func _input(event: InputEvent) -> void:
	# Only update if the camera is the current camera
	if (_camera.is_current() && event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		# Get old transform basis
		var old_basis = _character_body.global_transform.basis
		
		# Left and right
		_character_body.rotate_y(-event.relative.x * Settings.camera_sensitivity_horizontal * 0.01)
		
		# Match horizontal velocity to old, but in the new direction
		var new_basis := _character_body.global_transform.basis
		var delta_basis := new_basis * old_basis.inverse()
		_character_body.velocity = delta_basis * _character_body.velocity
		
		# Up and down
		_pivot.rotate_x(-event.relative.y * Settings.camera_sensitivity_vertical * 0.01)
		
		# Clamp rotation to ensure proper rotational limits when looking up and down
		_pivot.rotation.x = clamp(_pivot.rotation.x, deg_to_rad(max_camera_down_angle), deg_to_rad(max_camera_up_angle))
	
	if (event is InputEventKey):
		# Change Game Focus
		if (Input.is_action_just_pressed(Keybinds.ActionNames.ESCAPE)):
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		# Change Camera POV
		if (Input.is_action_just_pressed(Keybinds.ActionNames.CHANGE_CAMERA_POV)):
			setToThirdPerson() if (is_first_person) else setToFirstPerson()

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Set the body node of the character this camera is attached to
## @param character_body: Body node of the character
func setCharacterBody(character_body: CharacterBody3D) -> void:
	_character_body = character_body

## Get the actual camera node, typically used to set the current camera of the client
## @returns Camera3D: Actual camera node, not the spring arm 3d
func getCamera() -> Camera3D:
	return _camera

func setToCurrentCamera() -> void:
	_camera.current = true

## Set the camera to the first person position
func setToFirstPerson() -> void:
	is_first_person = true
	
	_spring_arm.set_collision_mask(0)
	_spring_arm.set_length(0.0)
	_spring_arm.set_position(_FIRST_PERSON_CAMERA_POSITION_OFFSET)
	_spring_arm.set_rotation_degrees(_FIRST_PERSON_CAMERA_ROTATION_OFFSET)

## Set the camera to the third person position
func setToThirdPerson() -> void:
	is_first_person = false
	
	_spring_arm.set_collision_mask(1)
	_spring_arm.set_length(1.0)
	_spring_arm.set_position(_THIRD_PERSON_CAMERA_POSITION_OFFSET)
	_spring_arm.set_rotation_degrees(_THIRD_PERSON_CAMERA_ROTATION_OFFSET)

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
