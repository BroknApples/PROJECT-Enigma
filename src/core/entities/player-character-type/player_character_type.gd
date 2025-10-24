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

# TODO: Add a collision debounce to every collision node that can move around (like players)
# that DONT die in one hit
# CURRENT LIST:
#
# PLAYERS
# PROJECTILES
# ANYTHING IN THE FUTURE TOO

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

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# SIGNAL HELPERS

## @OVERRIDE
## Player pressed the jump keybind
func _handleJumpKeyPressed() -> void:
	# ON FLOOR
	if (_position_state == PositionState.ON_FLOOR):
		applyJump()
	# IN AIR
	elif (_position_state == PositionState.IN_AIR && _air_jump_count > 0):
		applyJump()
		_air_jump_count -= 1
		return
	
	# Set position state to " "
	_position_state = PositionState.IN_AIR
	
	# Wait until the character is back on the ground
	await _waitUntilOnFloor()
	
	# Now set position state to "ON_FLOOR" and reset air jump count
	_position_state = PositionState.ON_FLOOR
	_air_jump_count = _total_air_jump_count

# OTHER

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _physics_process(delta: float) -> void:
	# Add gravity
	_runGravityPhysics(delta)
	
	# Set weapon rotation to whatever the camera raycaster is looking at
	var raycast_data := _camera_pivot.getRaycastData()
	if (raycast_data != {}): # If raycast data is null, just dont rotate the weapon for now
		var raycast_position: Vector3 = raycast_data.get(Utils.IntersectRayData.POSITION)
		
		# TODO: Set ACTIVE weapon rotation, for now just set the current weapon
		# TODO: Fix rotation from being sideways and immediately snapping, to lerping and
		# looking up/down most of the time
		
		# NOTE: TODO: Once it reaches like 30 degrees of rotation in the normal direction, I want it
		# to change the axis of rotation or something like that
		
		
		# TESTING
		var blaster: WeaponType = _weapons.get_node(^"BlasterWeapon")
		blaster.look_at(raycast_position, Vector3.UP)

func _ready() -> void:
	# Set metadata
	self.set_meta(Metadata.PLAYER_TYPE, true)
	
	# Call important functions in the base class
	await super._ready()
	
	# beg TESTING: RELOCATE NODES IN THE WORLD AREA
	self.position.y += 10
	
	self.position.x -= 5
	# end TESTING: RELOCATE NODES IN THE WORLD AREA
	
	await get_tree().process_frame
	
	# Players should always process themselves since they will be the authority
	self.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
	# Set initial stats
	_health_component.setBaseMaximumHealth(_INITIAL_BASE_MAX_HP)
	_defense_component.setBaseDefense(_INITIAL_BASE_DEFENSE)
	
	# If the current client is the one that has control, setup some things
	self.setPlayerToActive()

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Initialize data
## @param initialize_arr: Array that holds data to initialize the node, NOTE: arr[0] is always the UUID
func initialize(initialize_arr: Array) -> void:
	# Set meta
	UUID.setMetadata(self, initialize_arr[UUID.INITIALIZER_ARRAY_UUID_INDEX])
	
	# Emit signals
	_initialized = true
	SIG_initialized.emit()

## Sets up processes that need to be set when the player is the locally controlled player
func setPlayerToActive() -> void:
	# Setup a movement script
	var player_input: PackedScene = AssetManager.getAssetOneTime(AssetManager.Assets.PLAYER_INPUT_SCENE)
	var player_input_node: Node3D = player_input.instantiate()
	self.add_child(player_input_node)
	
	# Set to the current client to this camera pov
	self.getCameraPivot().setToCurrentCamera()
	
	# TODO: Eventually check settings to see if the player preferes (or was last in) 1st/3rd person
	self.getCameraPivot().setToFirstPerson()

## Wrapper for move_and_slide()
## NOTE: Should only really be called from the player input script
func doMovement() -> void:
	_character_body.move_and_slide()

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
