extends Node

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
##
## Clock Singleton
##
## This file defines a way to get specific points in time in
## the program along with the time of the outside world
##

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

## The TimePoint Class defines a a given point in the runtime of the game
## 
## Usage:
## var time_point = TimePoint.new()       # -> Gets the current time when creating new object
## time_point.setToCurrentRuntime()       # -> Sets an existing TimePoint variable to the current runtime
## var runtime_ms = Utils.TimePoint.now() # -> Gets the current runtime of the entire program in milliseconds
class TimePoint:
	const _MILLISECONDS_PER_HOUR: int = 3_600_000
	const _MILLISECONDS_PER_MINUTE: int = 60_000
	const _MILLISECONDS_PER_SECOND: int = 1_000
	const _SECONDS_PER_MINUTE: int = 60
	const _MINUTES_PER_HOUR: int = 60
	
	var _hours := 0
	var _minutes := 0
	var _seconds := 0
	var _milliseconds := 0
	
	## Initialize new object with current time
	func _init() -> void:
		_formatFromMilliseconds(Clock.TimePoint.now())
	
	## Format milliseconds to a correct TimePoint
	func _formatFromMilliseconds(milliseconds: int) -> void:
		# Idea is to repeatedly remove 1 hour until milliseconds is less
		# than an hours, then do the same for minutes, and seconds
		# then just assingn the leftover to milliseconds
		while (milliseconds >= _MILLISECONDS_PER_HOUR):
			milliseconds -= _MILLISECONDS_PER_HOUR
			_hours += 1
		while (milliseconds >= _MILLISECONDS_PER_MINUTE):
			milliseconds -= _MILLISECONDS_PER_MINUTE
			_minutes += 1
		while (milliseconds >= _MILLISECONDS_PER_SECOND):
			milliseconds -= _MILLISECONDS_PER_SECOND
			_seconds += 1
		_milliseconds += milliseconds
	
	## Format the time stored internally in the TimePoint object
	func _format() -> void:
		while (_milliseconds >= _MILLISECONDS_PER_SECOND):
			_milliseconds -= _MILLISECONDS_PER_SECOND
			_seconds += 1
		while (_seconds >= _SECONDS_PER_MINUTE):
			_seconds -= _SECONDS_PER_MINUTE
			_minutes += 1
		while (_minutes >= _MINUTES_PER_HOUR):
			_minutes -= _MINUTES_PER_HOUR
			_hours += 1
	
	## Get current time in milliseconds
	## @returns int: Current program runtime in milliseconds
	static func now() -> int:
		return Time.get_ticks_msec()
	
	## Add some time to the a TimePoint
	## @param milliseconds: Milliseconds to add
	## @param seconds: Seconds to add
	## @param minutes: Minutes to add
	## @param hours: Hours to add
	func addTime(milliseconds: int, seconds: int, minutes: int, hours: int) -> void:
		# Add additional time
		_milliseconds += milliseconds
		_seconds += seconds
		_minutes += minutes
		_hours += hours
		
		# Format the new time stored in this object
		_format()
	
	## Set the current TimePoint object to the current runtime
	func setToCurrentRuntime() -> void:
		_formatFromMilliseconds(Clock.TimePoint.now())
	
	## Get array of integers that defines the current time
	## Formatted: [Hours, Minutes, Seconds, Milliseconds]
	## @returns Array[int]: time data
	func getTimeArray() -> Array[int]:
		return [_hours, _minutes, _seconds, _milliseconds]
		
	## Get the current runtime of the program in string format
	## Formated: HH:MM:SS:MS
	## @param decorations: Include chevrons around string(<HH:MM:SS:MS>)? Default = No
	## @returns String: String-form of a TimePoint
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
	
	## Get the hours-place of a TimePoint
	## @returns int: Number of hours in the hours-place
	func getHours() -> int: return _hours
	
	## Get the minutes-place of a TimePoint
	## @returns int: Number of minutes in the minutes-place
	func getMinutes() -> int: return _minutes
	
	## Get the seconds-place of a TimePoint
	## @returns int: Number of seconds in the seconds-place
	func getSeconds() -> int: return _seconds
	
	## Get the milliseconds-place of a TimePoint
	## @returns int: Number of milliseconds in the milliseconds-place
	func getMilliseconds() -> int: return _milliseconds

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

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

func secondsToMilliseconds(seconds: float) -> float:
	return seconds * 1000.0

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
