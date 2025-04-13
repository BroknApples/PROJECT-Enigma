extends Node

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## EventScheduler
## 
## Set events to be ran at specific time intervals, such as:
## Autosave every 15 minutes, printing something every 10 seconds
##
## NOTE: Only add functions that are not dependant on specific conditions
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

# Scheduler Timings -- always in ms
const ONE_HUNDRED_MILLISECONDS: int 	= 100
const FIVE_HUNDRED_MILLISECONDS: int 	= 500
const ONE_SECOND: int 					= 1000
const FIVE_SECONDS: int 				= 5000
const TEN_SECONDS: int 					= 10000
const THIRTY_SECONDS: int 				= 30000
const ONE_MINUTE: int 					= 60000
const FIVE_MINUTES: int 				= 300000
const TEN_MINUTES: int 					= 600000
const THIRTY_MINUTES: int 				= 1800000
const ONE_HOUR: int 					= 3600000

## Holds the events that will be called at any given time slice
## { int : Array[object/class] }
var scheduler := {
	ONE_HUNDRED_MILLISECONDS: 		[null],
	FIVE_HUNDRED_MILLISECONDS: 		[null],
	ONE_SECOND: 					[null],
	FIVE_SECONDS: 					[null],
	TEN_SECONDS: 					[null],
	THIRTY_SECONDS: 				[null],
	ONE_MINUTE: 					[null], 
	FIVE_MINUTES: 					[null],
	TEN_MINUTES: 					[null],
	THIRTY_MINUTES: 				[null],
	ONE_HOUR: 						[null]
}

## Time until the next processing event for each time slice
## { int : float }
var previous_frametimes := {
	ONE_HUNDRED_MILLISECONDS: 		ONE_HUNDRED_MILLISECONDS,
	FIVE_HUNDRED_MILLISECONDS: 		FIVE_HUNDRED_MILLISECONDS,
	ONE_SECOND: 					ONE_SECOND,
	FIVE_SECONDS: 					FIVE_SECONDS,
	TEN_SECONDS: 					TEN_SECONDS,
	THIRTY_SECONDS: 				THIRTY_SECONDS,
	ONE_MINUTE: 					ONE_MINUTE, 
	FIVE_MINUTES: 					FIVE_MINUTES,
	TEN_MINUTES: 					TEN_MINUTES,
	THIRTY_MINUTES: 				THIRTY_MINUTES,
	ONE_HOUR: 						ONE_HOUR
}

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

## Check each time slice and run events if it is time
## @param delta: Time since last frame
func _process(delta: float) -> void:
	# NOTE: The upcoming loops could be combined, but it may introduce a large delay between the first event
	# and final event to be checked. Therefore I have chosen to not combine them, change with caution.
	
	# Set new time until process event for each time slice
	for time_key in previous_frametimes.keys():
		previous_frametimes[time_key] -= delta
	
	#
	for time_key in previous_frametimes.keys():
		# Process events
		if (previous_frametimes[time_key] <= 0.0):
			for callable in scheduler[time_key]:
				# Call function next frame to ensure object safety
				Utils.deferCallable(callable)
			
			# Reset time until next processing
			previous_frametimes[time_key] = time_key

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

# TODO: MAY CHANGE CALLABLE TO A VARIANT VARIABLE THAT WILL ALWAYS BE THE CLASS THAT CAN CALL SOME FUNCTION
# IT MAY BE NAMED: processTimeSliceEvents

## Add item to event scheduler
## @param callable: Function to call
## @param time_slice: Which time slice to add it in
func push(callable: Callable, time_slice: int) -> void:
	scheduler[time_slice].push_back(callable)

## Remove item from event scheduler
## @param callable: Function to remove
func remove(callable: Callable) -> void:
	# TODO: Implement.
	pass

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
