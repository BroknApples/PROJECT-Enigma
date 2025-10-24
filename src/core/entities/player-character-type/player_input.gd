extends Node3D

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## PlayerInput
## 
## Defines all input actions for the CharacterBody that is the player.
##
## NOTE: This does NOT include weapon actions; those will have their
## own input script
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

@onready var _PLAYER: PlayerCharacterType = self.get_parent() ## The owner of this script will always be the immediate parent

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

## Handle inputs
func _input(event: InputEvent) -> void:
	if (event is InputEventKey):
		# WASD Movement
		if (Input.is_action_just_pressed(Keybinds.ActionNames.MOVE_FORWARD) ||
			Input.is_action_just_pressed(Keybinds.ActionNames.MOVE_LEFT) ||
			Input.is_action_just_pressed(Keybinds.ActionNames.MOVE_BACKWARD) ||
			Input.is_action_just_pressed(Keybinds.ActionNames.MOVE_RIGHT)):
			_PLAYER.SIG_movement.emit()
		# JUMP
		elif (Input.is_action_pressed(Keybinds.ActionNames.JUMP)):
			_PLAYER.SIG_jump.emit()
		# SPRINT
		elif (Input.is_action_just_pressed(Keybinds.ActionNames.SPRINT)):
			_PLAYER.SIG_sprint.emit()
		# CROUCH
		elif (Input.is_action_just_pressed(Keybinds.ActionNames.CROUCH)):
			_PLAYER.SIG_crouch.emit()
	elif (event is InputEventMouseMotion):
		# TODO: Will probably need to implement body turning
		# code here once I move away from bean characters
		pass

func _physics_process(delta: float) -> void:
	# Apply movement
	var input_dir := Input.get_vector(Keybinds.ActionNames.MOVE_LEFT
									, Keybinds.ActionNames.MOVE_RIGHT
									, Keybinds.ActionNames.MOVE_FORWARD
									, Keybinds.ActionNames.MOVE_BACKWARD)
	
	var movement_vector := Vector3(input_dir.x, 0.0, input_dir.y)
	_PLAYER.applyMovementVector(movement_vector, delta)
	_PLAYER.doMovement()

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
