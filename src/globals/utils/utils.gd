@tool
extends Node

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Utils Singleton
## 
## Utility functions that help reduce reused code
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

## Pair type similar to C++ Counterpart
# TODO: Look into somehow predefining the the type of each
class Pair:
	var first: Variant
	var second: Variant
	
	func _init(init_first: Variant, init_second: Variant) -> void:
		first = init_first
		second = init_second

## Defines which numbers correspond to what collision layer
enum CollisionLayers {
	# NORMAL LAYERS
	ALL = 0,
	NON_GHOST_TERRAIN,
	ANY_ENTITY,
	PLAYER_ENTITY,
	ENEMY_ENTITY,
	PROJECTILE_ENTITY,
	
	# TEAMS
	TEAM_PLAYER = 23,
	TEAM_ENEMY,
	TEAM_NEUTRAL,
}

## Holds the keys that will exist when using an intersect_ray() to query a raycaster
class IntersectRayData:
	const POSITION: StringName = &"position" ## Vector3 World-space position where the ray hit
	const NORMAL: StringName = &"normal" ## Vector3 mThe surface normal at the point of impact
	const COLLIDER: StringName = &"collider" ## Object mThe actual physics object (e.g. node) that was hit
	const COLLIDER_ID: StringName = &"collider_id" ## int The instance ID (RID) of the collider
	const SHAPE: StringName = &"shape" ## int The index of the specific shape within the collider that was hit
	const RESOURCE_ID: StringName = &"rid" ## RID The unique RID of the hit shape
	const FACE_INDEX: StringName = &"face_index" ## int The face index hit on the mesh (only for MeshInstance3D, optional)
	const OBJECT_ID: StringName = &"object_id" ## int The object ID of the collider (equivalent to collider.get_instance_id())
	const BARRIER: StringName = &"barrier" ## bool Whether a barrier was hit (used internally for motion APIs, usually false)

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

## Maximum time an inactive entity can survive in the game world
const INACTIVE_ENTITY_DESPAWN_TIME: float = 60.0 

## Not the root of the scene tree, but the root of the main game nodes
var GAME_ROOT: Node 

## Simple random number generator
var RNG := RandomNumberGenerator.new() 

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

# NOTE:  TEMPLATE

### Exit requested
#func _notification(what: int) -> void:
	#if (what == NOTIFICATION_WM_CLOSE_REQUEST):
		#Utils.exitGame()

# NOTE: TEMPLATE

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Exit game, flush logger first
func exitGame() -> void:
	Logger.flushBuffers()
	get_tree().quit()

## Sleep some amount of time in seconds
## @param seconds: Seconds to sleep for
func sleep(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

## Run a callable the next frame to ensure object safety
## @param callable: Function to be deferred
func deferCallable(callable: Callable) -> void:
	await get_tree().process_frame
	callable.call()

## Remove any non-digit characters from a string
## @param string: String to strip non-digits from
func stripNonDigits(string: String) -> String:
	var length = string.length()
	if length == 0: return "" # Empty text
	
	# Stop user from inputting anything other than numbers
	for i in range(length):
		if (string[i].to_int() == 0 && string[i] != '0'):
			return string.substr(0, i) + string.substr(i + 1, length)
	
	return string

## Write a string to a file; always write in chunks of 4096 chars to be safe
## @param file_path: Path to the file
## @param string: String to write
## @param appending: Should the string be appended to the end of the file?
func writeToFile(file_path: String, string: String, appending: bool = false) -> void:
	var file: FileAccess
	if (appending):
		file = FileAccess.open(file_path, FileAccess.READ_WRITE)
		file.seek_end()
	else:
		file = FileAccess.open(file_path, FileAccess.WRITE)
	
	
	# Error opening file
	if (!file):
		Logger.logMsg("Could not open file [%s]" % [file_path], Logger.Category.ERROR)
		return
	
	# Write in chunks of 4096 chars
	const CHUNK_SIZE: int = 4096
	var i := 0
	while i < string.length():
		var end = min(i + CHUNK_SIZE, string.length())
		file.store_string(string.substr(i, end - i))
		i += CHUNK_SIZE
	
	file.close()

## Given a normal acceleration value, get an approximated acceleration strength value used in
## Utils.exponentialAcceleration()
## @param acceleration: Normal acceleration
## @param maximum_speed: Maximum speed
## @returns float: Acceleration strength value
func accelerationToAccelerationStrength(acceleration: float, maximum_speed: float) -> float:
	if (maximum_speed <= 0.0):
		# Divide by 0 error
		return 0.0
	
	var ratio = acceleration / maximum_speed
	if (ratio >= 1.0):
		return INF  # Instant acceleration
	elif (ratio <= 0.0):
		return 0.0  # No acceleration
	else:
		return -log(1.0 - ratio)

## Accelerate strongly at first, then slowly decrease acceleration over time,
## NOTE: ChatGPT my goat for this formula (I at least thought of the idea though)
## @param current_speed: Current velocity
## @param target_speed: Maximum velocity
## @param acceleration_strength: Heuristic that determines the speed at which the target speed is met
## @param delta: Time since last frame (in seconds)
## returns: float: Accelerated movement speed
func exponentialAcceleration(current_speed: float, target_speed: float, acceleration_strength: float, delta: float) -> float:
	# The acceleration_strength value must be positive
	if (acceleration_strength < 0.0): return current_speed
	
	return lerp(current_speed, target_speed, 1.0 - exp(-acceleration_strength * delta))

func getChunkDataNode() -> ChunkData:
	if (GAME_ROOT == null):
		return null
		
	#**********************************************#
	# Find the world data node from the game root,
	# to do this, start from the game root and find
	# a node that has the proper metadata tag,
	# (Metadata.WORLD_NODE). Once that happens
	# Ensure the function for getting the ChunkData
	# class exists before using it
	#**********************************************#
	for node in GAME_ROOT.get_children():
		# Worlds must have a WORLD_NODE metadata tag attached to them to be valid
		if (node.has_meta(Metadata.WORLD_NODE)):
			# The getChunkData() function is the method for getting the ChunkData class from a world
			if (node.has_method("getChunkData")):
				return node.getChunkData()
			else:
				# If the method does NOT exist, then its an invalid world node
				return null
	
	# Nothing was found that contained the correct metadata, so just return null
	return null

## Get the NodePath to a node, if it is not in the tree,
## temporarily add it to the tree, to get the path
## @param node: Node to get the path to
## @returns NodePath: Path to the node
func getNodePath(node: Node) -> NodePath:
	var node_path: NodePath = node.get_path()
	
	# If the node isn't in the scene tree, temporarily add it so we can get the path later
	if (!node.is_inside_tree()):
		# Temporarily add to a temporary node in the GAME_ROOT node
		GAME_ROOT.temp_node_3d.add_child(node)
		node_path = node.get_path()
		
		# Check if the node has a UUID, if so set its new path
		if (node.has_meta(Metadata.UUID)):
			var uuid: int = node.get_meta(Metadata.UUID)
			UUID.setUuidToNewNodePath(uuid, node_path)
	
	# Return the new path
	return node_path

## Disable the process functions of a node until it is initialized
## NOTE: The node must have the signal SIG_initialized and the private variable _initialized
## @param node: Node to set
func disableProcessingUntilInitialized(node: Node) -> void:
	# Wait until the node is initialized
	if (!node._initialized):
		# Until the node is initialized, do not run process functions
		node.set_process_mode(Node.PROCESS_MODE_DISABLED)
		
		# TODO: Make it time out if it takes more than like 250ms or something and force quit
		await node.SIG_initialized
	
	node.set_process_mode(Node.PROCESS_MODE_ALWAYS)

## Waits until a node is ready before continuing
## @param node: Node to wait for
func waitUntilNodeReady(node: Node) -> void:
	if (!node.is_node_ready()):
		await node.ready

## Safely scales a node to avoid scale = 0
func safelyScaleNode(node: Node, scale: Vector3) -> void:
	# Clamp scale components to avoid zero
	var clamped_scale = Vector3(
		max(scale.x, 0.0001),
		max(scale.y, 0.0001),
		max(scale.z, 0.0001)
	)
	
	node.scale = clamped_scale

## Given a team, return all other teams that are NOT that one
## @param your_team: Team to check against
## @returns Array[int]: List of collision layers of other teams
func getOtherTeams(your_team: int) -> Array[int]:
	var other_teams: Array[int] = []
	
	# Just check each number between the first layer
	# that is a team and the last layer that is a team (+1)
	# and append if its not the same as 'your_team'
	for i in range(Utils.CollisionLayers.TEAM_PLAYER, Utils.CollisionLayers.TEAM_NEUTRAL + 1):
		if (i != your_team):
			other_teams.append(i)
	
	return other_teams

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
