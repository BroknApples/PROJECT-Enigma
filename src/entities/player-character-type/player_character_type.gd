extends CharacterType
class_name PlayerCharacterType

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## PlayerCharacterType
## 
## Simply a CharacterType, but with player controllability
##
## Ensure when using this to create players, first create an 
## inherited scene, then check any unwanted resource as 
## invisible/disabled when applicable
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

@onready var _hud := $CanvasLayer/Hud ## Heads up display of the player

const _INITIAL_BASE_MAX_HP: float = 100 ## Initial base max hp of the player
const _INITIAL_BASE_DEFENSE: float = 0 ## Initial base defense of the player

var _total_air_jump_count := 1 ## How many jumps are possible when in the air
var _air_jump_count := _total_air_jump_count ## How many jumps are still possible when in the air

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

## @OVERRIDE
## PLayer pressed the jump keybind
func _on_jump_key_pressed() -> void:
	if (_position_state == PositionState.ON_FLOOR):
		# ON FLOOR
		applyJump()
	elif (_position_state == PositionState.IN_AIR && _air_jump_count > 0):
		# IN AIR
		applyJump()
		print("air jump")
		_air_jump_count -= 1
		return
	
	# Set position state to " "
	_position_state = PositionState.IN_AIR
	
	# Wait until the character is back on the ground
	await _waitUntilOnFloor()
	
	# Now set position state to "ON_FLOOR" and reset air jump count
	_position_state = PositionState.ON_FLOOR
	_air_jump_count = _total_air_jump_count

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
			SIG_movement.emit()
		# JUMP
		if (Input.is_action_pressed(Keybinds.ActionNames.JUMP)):
			SIG_jump.emit()
		# SPRINT
		if (Input.is_action_just_pressed(Keybinds.ActionNames.SPRINT)):
			SIG_sprint.emit()
		# CROUCH
		if (Input.is_action_just_pressed(Keybinds.ActionNames.CROUCH)):
			SIG_crouch.emit()
	if (event is InputEventMouseMotion):
		# TODO: Will probably need to implement body turning code here once I move away from bean characters
		pass

func _physics_process(delta: float) -> void:
	# Add gravity
	_runGravityPhysics(delta)
	
	# Apply movemenet
	var input_dir := Input.get_vector(Keybinds.ActionNames.MOVE_LEFT
									, Keybinds.ActionNames.MOVE_RIGHT
									, Keybinds.ActionNames.MOVE_FORWARD
									, Keybinds.ActionNames.MOVE_BACKWARD)
	
	var movement_vector := Vector3(input_dir.x, 0.0, input_dir.y)
	applyMovementVector(movement_vector, delta)
	_character_body.move_and_slide()

func _ready() -> void:
	# Set signals
	SIG_jump.connect(_on_jump_key_pressed) # REDO Jump since we overwrote it
	
	# Set metadata
	self.set_meta(Metadata.PLAYER_TYPE, true)
	
	# Set initial stats
	_health_component.setBaseMaximumHealth(_INITIAL_BASE_MAX_HP)
	_defense_component.setBaseDefense(_INITIAL_BASE_DEFENSE)
	
	# Call important functions in the base class
	super._ready()

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
