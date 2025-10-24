extends CharacterBody3D
class_name CharacterType

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## CharacterType
## 
## CharacterType is the parent of both Player AND Enemy types
##
## Defines essential methods and variables that ALL child-types
## will use, including: collision, abilities.
##
## NOTE: Unusable without adding CollisionShapes3D or CollisionPolygon3d
## in the Colliders node
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

## Different states of movement a CharacterType can be in
enum MovementState {
	CROUCH,
	WALK,
	RUN,
	SLIDE,
}
## Different positions the character can be in (in the air, on the floor, on a slope, etc.)
enum PositionState {
	IN_AIR,
	ON_SLOPE,
	ON_FLOOR,
	ON_WALL,
}

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

signal SIG_initialized()

signal SIG_movement()
signal SIG_jump()
signal SIG_sprint()
signal SIG_crouch()

# Components
@onready var _hitbox_component := $HitboxComponent ## Hitbox Component
@onready var _health_component := $HealthComponent ## Health Component
@onready var _defense_component := $DefenseComponent ## Defense Component

# Random Nodes
@onready var _character_body := self ## Reference to the actual character body node
@onready var _canvas_layer := $CanvasLayer ## Canvas Layer
@onready var _head := $Head ## This node contains the camera as its only child. Used for rotation, etc. Just imagine ur actual head lol
@onready var _camera_pivot: PlayerCamera = _head.getCameraNode() ## Scene instance of the player camera with it's child nodes. NOTE: THIS IS NOT THE ACTUAL Camera3D NODE
@onready var _camera = _camera_pivot.getCamera() ## Actual camera node
@onready var _weapons: Node3D = _head.getWeaponsNode() ## List of weapons available for use (Can hold two max for players, otherwise can hold any amount)
# TODO: Force weapons max size to be three and add a primary, secondary,
# and melee weapon variable to hold which weapon is in which slot

# MOVEMENT
@export var _crouch_minimum_movement_speed: float = 2.75 ## While crouched, what speed does the character's velocity get set to the frame an input is detected
@export var _crouch_max_movement_speed: float = 3.5 ## How fast does the character move when crouching
@export var _crouch_initial_acceleration_speed: float = 1.80 ## While crouched, how much does the character's movement speed increase by each second (until the maximum speed is reached)

@export var _walk_minimum_movement_speed: float = 4.62 ## While walking, what speed does the character's velocity get set to the frame an input is detected
@export var _walk_max_movement_speed: float = 5.5 ## How fast does the character move when walking
@export var _walk_initial_acceleration_speed: float = 5.75 ## While walking, how much does the character's movement speed increase by each second (until the maximum speed is reached)

@export var _run_minimum_movement_speed: float = 8.875 ## While running, what speed does the character's velocity get set to the frame an input is detected
@export var _run_max_movement_speed: float = 47.5 ## How fast does the character move when running
@export var _run_initial_acceleration_speed: float = 4.69 ## While running, how much does the character's movement speed increase by each second (until the maximum speed is reached)

@export var _jump_velocity: float = 5.0 ## How fast does the character rise up during jumps
@export var _air_deceleration_speed: float = 0.178 ## How fast does the character decelerate when in the air

## Which object controls gravity for this character.
## The object must have a 'getGravity()' function,
## it must be named exactly as written above.
var _gravitational_authority: Node

var _movement_state := MovementState.WALK ## States of movement of the CharacterType
var _position_state := PositionState.ON_FLOOR ## Position states of the CharacterType
var _movement_speed_modifiers: Array[float] = [] ## Movement Speed modifiers

var _initialized: bool = false ## Is this node initialized

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

## Player pressed a movement keybind
func _on_movement_key_pressed() -> void:
	pass

## Method that actually calls the implementation function, used
## to override the function in child types
func _on_jump_key_pressed():
	_handleJumpKeyPressed()

## Player pressed the sprint keybind
func _on_sprint_key_pressed() -> void:
	_handleSprintKeyPressed()

## Player pressed the crouch keybind
func _on_crouch_key_pressed() -> void:
	_handleCrouchKeyPressed()

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# SIGNAL HANDLERS

## Actually implements the handling of jumping 
func _handleJumpKeyPressed() -> void:
	# ON FLOOR
	if (_position_state == PositionState.ON_FLOOR):
		applyJump()
	
	# Set position state to "IN_AIR"
	_position_state = PositionState.IN_AIR
	
	# Wait until the character is back on the ground
	await _waitUntilOnFloor()
	
	# Now set position state to "ON_FLOOR"
	_position_state = PositionState.ON_FLOOR

## Actually implements the sprint key
func _handleSprintKeyPressed() -> void:
	# TODO: Check if player is on the floor, if not, then call some signal that will
	# wait until the character is on the floor then set the character to sprint
	if (_movement_state != MovementState.RUN):
		_movement_state = MovementState.RUN
	else:
		_movement_state = MovementState.WALK

## Actually implements the crouch key
func _handleCrouchKeyPressed() -> void:
	# NOTE: Only allow crouch when on the floor, and do not queue a crouch when in the air, unlike sprint
	if (_movement_state != MovementState.CROUCH && _character_body.is_on_floor()):
		_movement_state = MovementState.CROUCH
	else:
		_movement_state = MovementState.WALK

# OTHER

## Wait until the character body is back on the floor
func _waitUntilOnFloor() -> void:
	# Wait 5 frames initially, then check
	for i in range(5):
		await get_tree().physics_frame
	
	# Actually wait until the character is on the floor now
	while !_character_body.is_on_floor():
		await get_tree().physics_frame

## Run the default gravity physics on the CharacterBody3D
func _runGravityPhysics(delta: float) -> void:
	if (!_character_body.is_on_floor()):
		# Ensure the gravitational authority is valid before using
		if (_gravitational_authority != null && _gravitational_authority.has_method("getGravity")):
			var grav_vel = _gravitational_authority.getGravity() * delta
			_character_body.velocity.y -= grav_vel
		else:
			Logger.logMsg("CharacterType assigned an invalid gravitational_authority", Logger.Category.RUNTIME)
			UUID.freeUuid(self.get_meta(Metadata.UUID))
			_character_body.queue_free() # Handle by deleting node, TODO: Check if other things are necessary

## Apply all movement modifiers to a given movement speed
## @param movement_speed: Current movement speed, pre-modified
## @returns float: Movement speed, post-modification
func _applyMovementModifiersToMovementSpeed(movement_speed: float) -> float:
	# If there are no movement modifiers to consider, just return the same value
	if (_movement_speed_modifiers.size() == 0): return movement_speed
	
	# Set return value to the original speed, NOTE: modify this later in the function
	var modified_movement_speed := movement_speed
	
	# Average of movement modifiers
	var average: float = _movement_speed_modifiers.reduce(func(a: float , b: float): return ((a + b) / 2.0))
	
	# Apply different modifications based on the current movement state
	match (_movement_state):
		MovementState.CROUCH:
			# Use average value since it is the expected result
			modified_movement_speed = modified_movement_speed * average
		MovementState.WALK:
			# Use average value since it is the expected result
			modified_movement_speed = modified_movement_speed * average
		MovementState.RUN:
			# Use average value since it is the expected result
			modified_movement_speed = modified_movement_speed * average
		_:
			pass
	
	return modified_movement_speed

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

## Set CharacterType Defaults
func _ready() -> void:
	# Set metadata
	self.set_meta(Metadata.CHARACTER_TYPE, true)
	
	# Wait until the node is initialized. NOTE: Disables processing until it is initialized
	await Utils.disableProcessingUntilInitialized(self)
	
	# Apply the node_path to the UUID dictionary
	UUID.assignNodeToDictionary(Utils.getNodePath(self), self.get_meta(Metadata.UUID))
	
	# Set signals
	SIG_movement.connect(_on_movement_key_pressed)
	SIG_jump.connect(_on_jump_key_pressed)
	SIG_sprint.connect(_on_sprint_key_pressed)
	SIG_crouch.connect(_on_crouch_key_pressed)
	
	_camera_pivot.setPlayerBody(_character_body)
	
	# Set default gravitational authority
	_gravitational_authority = getDefaultGravitationalAuthorityNode()
	
	# The node was not assigned a valid gravitational authority, so handle.
	if (_gravitational_authority == null):
		Logger.logMsg("CharacterType assigned a 'null' gravitational_authority", Logger.Category.RUNTIME)
		UUID.freeUuid(self.get_meta(Metadata.UUID))
		_character_body.queue_free() # Handle by deleting node, TODO: Check if other things are necessary

## Default physics interpretation for a CharacterType.
## Implements gravity
func _physics_process(delta: float) -> void:
	# Add gravity
	_runGravityPhysics(delta)
	
	# Apply actual movement
	_character_body.move_and_slide()

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Initialize important values for character bodies...
## NOTE: You MUST ONLY run this when the character boy is located in
## one of the top level child nodes of the Entities node in a
## 'chunk_data' object
func initialize(initialize_arr: Array) -> void:
	UUID.setMetadata(self, initialize_arr[UUID.INITIALIZER_ARRAY_UUID_INDEX])
	
	# TODO: Whatever else here
	
	# Set this projectile as initialized
	_initialized = true
	SIG_initialized.emit()

## Get the camera spring arm
## @returns SpringArm3D: Camera spring arm
func getCameraPivot() -> Node3D:
	return _camera_pivot

## Get the camera spring arm's actual camera
## @returns Camera3D: Actual camera object
func getCamera() -> Camera3D:
	return _camera_pivot.getCamera()

## Returns the default node that handles gravitational constants
## @returns Node: Object containing the 'getGravity()' function
func getDefaultGravitationalAuthorityNode() -> Node:
	# The node structure for a ChunkData instance (Which is where character
	# bodies SHOULD be implemented) is structured as such:
	#
	# ChunkData: (3)
	# --> Entities: (2)
	#     --> Players: (1)
	#         --> CharacterBody3D (self)
	#
	# ChunkData is the desired node that contains the script with 'getGravity()'
	# Thus, we go back 3 parent nodes for the correct Node
	if ((self.get_parent() != null) && (self.get_parent().get_parent() != null)):
		return self.get_parent().get_parent().get_parent()
	else:
		return null

## Set the CharacterType to a new movement_state
## @param new_movement_state: New movement state of the CharacterType
func setMovementState(new_movement_state: MovementState) -> void:
	_movement_state = new_movement_state

## Apply a jump movement to the character
func applyJump() -> void:
	_character_body.velocity.y = _jump_velocity

## Move the character type in a given Vector3 direction
## @param movement_input: Direction and velocity to move with (MUST BE BETWEEN 0 and 1, but clamped anyways)
## @param delta: Time since last frame
func applyMovementVector(movement_vector: Vector3, delta: float) -> void:
	# If the current velocity is 0 and the new velocity is zero, we can just skip to save time
	if (_character_body.velocity == Vector3.ZERO && movement_vector == Vector3.ZERO):
		return
	
	
	# Each Movement vector value must be between 0 and 1
	movement_vector.clamp(Vector3(0.0, 0.0, 0.0), Vector3(1.0, 1.0, 1.0))
	
	var direction = _character_body.transform.basis * movement_vector.normalized() # Get correct movement direction
	
	
	# Resists movement inputs. 1.0 = no resistance, 0.0 = maximum resistance
	var friction: float
	
	# Get constants from position state
	match(_position_state):
		PositionState.ON_FLOOR:
			# TODO: Get friction from the environment or something
			friction = 0.9
		
		PositionState.IN_AIR:
			friction = 1.0
		
		PositionState.ON_SLOPE:
			pass
		
		PositionState.IN_AIR:
			pass
		
		_:
			pass
		
	# Ensure friction is in the proper range
	clamp(friction, 0.0, 1.0)
	
	
	# Movement speed constants
	var actual_maximum_movement_speed: float
	var actual_minimum_movement_speed: float
	var actual_acceleration: float
	var deceleration_speed: float
	
	# Get constants based on movement state
	match (_movement_state):
		MovementState.CROUCH:
			actual_minimum_movement_speed = _applyMovementModifiersToMovementSpeed(_crouch_minimum_movement_speed) * friction
			actual_maximum_movement_speed = _applyMovementModifiersToMovementSpeed(_crouch_max_movement_speed) * friction
			actual_acceleration = _applyMovementModifiersToMovementSpeed(_crouch_initial_acceleration_speed) * friction
			deceleration_speed = actual_maximum_movement_speed * 5.3
		
		MovementState.WALK:
			actual_minimum_movement_speed = _applyMovementModifiersToMovementSpeed(_walk_minimum_movement_speed) * friction
			actual_maximum_movement_speed = _applyMovementModifiersToMovementSpeed(_walk_max_movement_speed) * friction
			actual_acceleration = _applyMovementModifiersToMovementSpeed(_walk_initial_acceleration_speed) * friction
			deceleration_speed = actual_maximum_movement_speed * 4.27
		
		MovementState.RUN:
			actual_minimum_movement_speed = _applyMovementModifiersToMovementSpeed(_run_minimum_movement_speed) * friction
			actual_maximum_movement_speed = _applyMovementModifiersToMovementSpeed(_run_max_movement_speed) * friction
			actual_acceleration = _applyMovementModifiersToMovementSpeed(_run_initial_acceleration_speed) * friction
			
			deceleration_speed = actual_maximum_movement_speed * 0.98
		
		_:
			pass
	
	# Change deceleration speed if the character is in the air
	if (_position_state == PositionState.IN_AIR):
		deceleration_speed = _air_deceleration_speed
	
	# Calculate acceleration strength for exponential acceleration
	var acceleration_strength = Utils.accelerationToAccelerationStrength(actual_acceleration, actual_maximum_movement_speed)
	
	#
	# X-DIRECTION MOVEMENT
	#
	if (direction.x == 0.0):
		#
		# Decelerate if no input in the X-direction
		#
		_character_body.velocity.x = lerp(_character_body.velocity.x, 0.0, deceleration_speed * delta)
	else:
		#
		# Character is moving in the X-direction
		#
		
		# Calculate the accelerated X-velocity
		var accelerated_x_vel = Utils.exponentialAcceleration(_character_body.velocity.x, direction.x * actual_maximum_movement_speed, acceleration_strength, delta)
		accelerated_x_vel *= friction
		
		match (_position_state):
			PositionState.ON_FLOOR:
				#
				# Character is on the floor
				#
				if (abs(accelerated_x_vel) < actual_minimum_movement_speed):
					#
					# Character is under the minimum movement speed, so accelerate to it quickly for a smooth, but fast transition
					#
					_character_body.velocity.x = lerp(_character_body.velocity.x, direction.x * actual_minimum_movement_speed, 1)
				else:
					#
					# Character is above the minimum movement speed, so apply the formulated speed
					#
					_character_body.velocity.x = accelerated_x_vel
			
			PositionState.IN_AIR:
				#
				# Character is in the air
				#
				
				# TODO: Make it so the character can move in the air, but at a severely reduced speed.
				# Ensure that you cannot increase your speed at all so do like:
				# min(lerp(deceleration), speed * direction) or whatever would be right
				
				# Add air friction when in the air
				_character_body.velocity.x = lerp(_character_body.velocity.x, 0.0, deceleration_speed * delta)
	
	#
	# Z-DIRECTION MOVEMENT
	#
	if (direction.z == 0.0):
		#
		# Decelerate if no input in the Z-direction
		#
		_character_body.velocity.z = lerp(_character_body.velocity.z, 0.0, deceleration_speed * delta)
	else:
		#
		# Character is moving in the Z-direction
		#
		
		# Calculate the accelerated Z-velocity
		var accelerated_z_vel = Utils.exponentialAcceleration(_character_body.velocity.z, direction.z * actual_maximum_movement_speed, acceleration_strength, delta)
		accelerated_z_vel *= friction
		accelerated_z_vel *= friction
		
		match (_position_state):
			PositionState.ON_FLOOR:
				#
				# Character is on the floor
				#
				if (abs(accelerated_z_vel) < actual_minimum_movement_speed):
					#
					# Character is under the minimum movement speed, so accelerate to it quickly for a smooth, but fast transition
					#
					_character_body.velocity.z = lerp(_character_body.velocity.z, direction.z * actual_minimum_movement_speed, 1)
				else:
					#
					# Character is above the minimum movement speed, so apply the formulated speed
					#
					_character_body.velocity.z = accelerated_z_vel
			
			PositionState.IN_AIR:
				#
				# Character is in the air
				#
				
				# TODO: Make it so the character can move in the air, but at a severely reduced speed. 
				# Ensure that you cannot increase your speed at all so do like:
				# min(lerp(deceleration), speed * direction) or whatever would be right
				
				# Add air friction when in the air
				_character_body.velocity.z = lerp(_character_body.velocity.z, 0.0, deceleration_speed * delta)

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
