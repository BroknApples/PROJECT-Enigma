extends Node

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Utils
## 
## Utility functions that help reduce reused code
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

## The TimePoint Class defines a a given point in the runtime of the game
class TimePoint:
	const _MILLISECONDS_PER_HOUR: int = 3_600_000
	const _MILLISECONDS_PER_MINUTE: int = 60_000
	const _MILLISECONDS_PER_SECOND: int = 1_000
	
	var _hours: int
	var _minutes: int
	var _seconds: int
	var _milliseconds: int
	
	func _init() -> void:
		_format(Utils.TimePoint.now())
	
	## Format milliseconds to a correct TimePoint
	func _format(milliseconds: int) -> void:
		# Idea is to repeatedly remove 1 hour until milliseconds is less
		# than an hours, then do the same for minutes, and seconds
		# then just assingn the leftover to milliseconds
		
		while(milliseconds > _MILLISECONDS_PER_HOUR):
			milliseconds -= _MILLISECONDS_PER_HOUR
			_hours += 1
		while(milliseconds > _MILLISECONDS_PER_MINUTE):
			milliseconds -= _MILLISECONDS_PER_MINUTE
			_minutes += 1
		while(milliseconds > _MILLISECONDS_PER_SECOND):
			milliseconds -= _MILLISECONDS_PER_SECOND
			_seconds += 1
		_milliseconds = milliseconds
	
	## Get current time in milliseconds
	static func now() -> int:
		return Time.get_ticks_msec()
	
	## Get array of integers that defines the current time
	## Formatted: [Hours, Minutes, Seconds, Milliseconds]
	func getTimeArray() -> Array[int]:
		return [_hours, _minutes, _seconds, _milliseconds]
		
	## Get the current runtime of the program in string format
	## Formated: HH:MM:SS:MS
	## @param decorations: Include chevrons around string? Default = No
	func getTimeString(decorations: bool = false) -> String:
		const STRING_WIDTH: int = 15 # How wide will the string be at a minimum
		
		# Get string
		var string := ""
		if (decorations): string += "<"
		string += str(_hours) + ":"
		string += str(_minutes).pad_zeros(2) + ":"
		string += str(_seconds).pad_zeros(2) + ":"
		string += str(_milliseconds).pad_zeros(3)
		if (decorations): string += ">"
		
		# Fill with air
		if (decorations): string += " ".repeat(2) # Fill with two more air chars if decorations are on
		string += " ".repeat(STRING_WIDTH - string.length()) # Fill with air
		
		return string
	
	func getHours() -> int: return _hours
	func getMinutes() -> int: return _minutes
	func getSeconds() -> int: return _seconds
	func getMilliseconds() -> int: return _milliseconds

## Pair type similar to C++ Counterpart
# TODO: Look into somehow predefining the the type of each
class Pair:
	var first
	var second
	
	func _init(init_first, init_second) -> void:
		first = init_first
		second = init_second

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

const SERVER_RPC_ID: int = 1 # Server @rpc ID should always be 1

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Exit game, flush logger first
func exitGame() -> void:
	Logger.flushBuffers()
	get_tree().exit()

func secondsToMilliseconds(seconds: float) -> float:
	return seconds * 1000.0

## Run a callable the next frame to ensure object safety
## @param callable: Function to be deferred
func deferCallable(callable: Callable) -> void:
	await get_tree().process_frame
	callable.call()

## Remove any non-digit characters from a string
## @param str: String to check
func stripNonDigits(str: String) -> String:
	var length = str.length()
	if length == 0: return "" # Empty text
	
	# Stop user from inputting anything other than numbers
	for i in range(length):
		if (str[i].to_int() == 0 && str[i] != '0'):
			return str.substr(0, i) + str.substr(i + 1, length)
	
	return str

## Write a string to a file, always write in chunks of 4096 chars to be safe
## @param file_path: Path to the file
## @param str: String to write
func writeToFile(file_path: String, str: String) -> void:
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	
	# Error opening file
	if (!file):
		Logger.logMsg("Could not open file [%s]" % [file_path], Logger.Category.ERROR)
		return
	
	# Write in chunks of 4096 chars
	const CHUNK_SIZE: int = 4096
	var i := 0
	while i < str.length():
		var end = min(i + CHUNK_SIZE, str.length())
		file.store_string(str.substr(i, end - i))
		i += CHUNK_SIZE
	
	file.close()

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
