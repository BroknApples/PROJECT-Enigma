extends Node3D
class_name PlayerCamera

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

@onready var _player_body: PlayerCharacterType = $".".get_parent().get_parent() ## The player_character_type that owns this player camera
@onready var _head := $".".get_parent()
@onready var _pivot := $"."
@onready var _spring_arm := $SpringArm3D
@onready var _camera := $SpringArm3D/Camera3D
@onready var _raycast_3d := $SpringArm3D/Camera3D/RayCast3D ## Simple raycaster for checking what the camera is looking at
@onready var _raycaster_debug_mesh := $SpringArm3D/Camera3D/DebugMeshInstance3D ## Mesh used to show where the raycaster is looking when debugging

const _FIRST_PERSON_CAMERA_POSITION_OFFSET: Vector3 = Vector3(0.0, 0.0, 0.0) ## Position Offset used when the camera is in 1st-person mode
const _FIRST_PERSON_CAMERA_ROTATION_OFFSET: Vector3 = Vector3(0.0, 0.0, 0.0) ## Rotation Offset used when the camera is in 1st-person mode

const _THIRD_PERSON_CAMERA_POSITION_OFFSET: Vector3 = Vector3(0.56, 0.786, 2.068) ## Position Offset used when the camera is in 3rd-person mode
const _THIRD_PERSON_CAMERA_ROTATION_OFFSET: Vector3 = Vector3(-1.6, 3.6, -0.1) ## Rotation Offset used when the camera is in 3rd-person mode

@export var _raycaster_range: float = 500.0 ## Up to how many units can the raycaster check
@export var _show_raycaster_debug_mesh: bool = false: ## Should the raycaster debug mesh be shown in game?
	set(value):
		_show_raycaster_debug_mesh = value
		_raycaster_debug_mesh.visible = value

# TODO: May wanna change these two variables to const? idk if i will need to change em later yet
var max_camera_up_angle := 74.0 ## Maximum angle you can look upwards
var max_camera_down_angle := -82.0 ## Maximum angle you can look downwards

var is_first_person := true

var _current_frame_raycast_data: Dictionary = {} ## Holds the data the raycast node queried this frame

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Query the raycaster to check what the camera is looking at this frame
## NOTE: Get data using 'getRaycastData()'
func _queryRaycast() -> void:
	var space_state = get_world_3d().direct_space_state
	var from = _raycast_3d.global_transform.origin
	var to = from + -_raycast_3d.global_transform.basis.z * _raycast_3d.target_position.length()
	
	# Create the query
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [_player_body] # Exclude the player node that owns this camera
	
	# Do and assign query data
	_current_frame_raycast_data = space_state.intersect_ray(query)

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _process(_delta: float) -> void:
	# Query raycaster
	_queryRaycast()

func _ready() -> void:
	if (!_player_body._initialized):
		set_process_mode(Node.PROCESS_MODE_DISABLED)
		await _player_body.SIG_initialized
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
	# TESTING
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# TESTING
	
	# Set raycaster debug mesh visibility
	_raycaster_debug_mesh.visible = _show_raycaster_debug_mesh
	
	# Set the raycaster range
	_raycast_3d.target_position.z = (_raycaster_range * -1)
	
	# Query raycaster once just to set it up
	_queryRaycast()

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Get the head of the player that owns this body
## @returns Node3D: Head of the player (This holds the camera pivot)
func getHead() -> Node3D:
	return _head

## Get the character body that owns this camera
## @returns PlayerCharacterType: Player that is using this camera
func getPlayerBody() -> PlayerCharacterType:
	return _player_body

## Get the actual camera node, typically used to set the current camera of the client
## @returns Camera3D: Actual camera node, not the spring arm 3d
func getCamera() -> Camera3D:
	return _camera

## Get the raycast data from this frame
func getRaycastData() -> Dictionary:
	return _current_frame_raycast_data

## Set the body node of the character this camera is attached to
## @param character_body: Body node of the character
func setPlayerBody(player_body: PlayerCharacterType) -> void:
	_player_body = player_body

## Set the current camera of the client to this camera
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
