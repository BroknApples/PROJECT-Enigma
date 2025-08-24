extends Node3D

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## PlayerCameraInput
## 
## Defines input implementation for a player camera. Will sync inputs from
## clients to the host
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

@onready var _camera_pivot: PlayerCamera = $".".get_parent()
@onready var _camera: Camera3D = _camera_pivot.getCamera()
@onready var _head: Node3D = _camera_pivot.getHead()
@onready var _player_body: PlayerCharacterType = _camera_pivot.getPlayerBody()

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# Wait until the camera is ready
	if (!_camera_pivot.is_node_ready()):
		set_process_mode(Node.PROCESS_MODE_DISABLED)
		await _camera_pivot.ready
		
		# Reassign variables
		_camera = _camera_pivot.getCamera()
		_head = _camera_pivot.getHead()
		_player_body = _camera_pivot.getPlayerBody()
		
		set_process_mode(Node.PROCESS_MODE_ALWAYS)

## Allow player to control camera
func _input(event: InputEvent) -> void:
	# Only the local client should be able to use inputs
	if (_player_body.has_meta(Metadata.CHARACTER_TYPE) &&
		_player_body.getOwnerPeerID() != P2PNetworking.getLocalPeerID()):
		return
	
	# Only update if the camera is the current camera
	if (_camera.is_current() && event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		# Get old transform basis
		var old_basis := _player_body.global_transform.basis
		
		# Left and right
		_player_body.rotate_y(-event.relative.x * Settings.camera_sensitivity_horizontal * 0.01)
		
		# Match horizontal velocity to old, but in the new direction
		var new_basis := _player_body.global_transform.basis
		var delta_basis := new_basis * old_basis.inverse()
		_player_body.velocity = delta_basis * _player_body.velocity
		
		# Up and down
		_head.rotate_x(-event.relative.y * Settings.camera_sensitivity_vertical * 0.01)
		
		# Clamp rotation to ensure proper rotational limits when looking up and down
		_head.rotation.x = clamp(_head.rotation.x, deg_to_rad(_camera_pivot.max_camera_down_angle), deg_to_rad(_camera_pivot.max_camera_up_angle))
	elif (event is InputEventKey):
		# Change Game Focus
		if (Input.is_action_just_pressed(Keybinds.ActionNames.ESCAPE)):
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		# Change Camera POV
		if (Input.is_action_just_pressed(Keybinds.ActionNames.CHANGE_CAMERA_POV)):
			if (_camera_pivot.is_first_person):
				_camera_pivot.setToThirdPerson()
			else:
				_camera_pivot.setToFirstPerson()

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
