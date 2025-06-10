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

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

var GAME_ROOT: Node ## Not the root of the scene tree, but the root of the main game nodes

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

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
