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

## Metadata
## { Callable : time_slice }

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

## Scheduler Timings -- always in ms
class TimeSlice:
	const ONE_HUNDRED_MILLISECONDS: int		= 100
	const FIVE_HUNDRED_MILLISECONDS: int	= 500
	const ONE_SECOND: int 					= 1_000
	const FIVE_SECONDS: int 				= 5_000
	const TEN_SECONDS: int 					= 10_000
	const THIRTY_SECONDS: int 				= 30_000
	const ONE_MINUTE: int 					= 60_000
	const FIVE_MINUTES: int 				= 300_000
	const TEN_MINUTES: int 					= 600_000
	const THIRTY_MINUTES: int 				= 1_800_000
	const ONE_HOUR: int 					= 3_600_000

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

## Holds the events that will be called at any given time slice
## { int : Array[object/class] }
var _scheduler := {
	TimeSlice.ONE_HUNDRED_MILLISECONDS: 	[],
	TimeSlice.FIVE_HUNDRED_MILLISECONDS: 	[],
	TimeSlice.ONE_SECOND: 					[],
	TimeSlice.FIVE_SECONDS: 				[],
	TimeSlice.TEN_SECONDS: 					[],
	TimeSlice.THIRTY_SECONDS: 				[],
	TimeSlice.ONE_MINUTE: 					[], 
	TimeSlice.FIVE_MINUTES: 				[],
	TimeSlice.TEN_MINUTES: 					[],
	TimeSlice.THIRTY_MINUTES: 				[],
	TimeSlice.ONE_HOUR: 					[]
}

## Time until the next processing event for each time slice
## { int : float }
var _time_until_execution := {
	TimeSlice.ONE_HUNDRED_MILLISECONDS: 	TimeSlice.ONE_HUNDRED_MILLISECONDS,
	TimeSlice.FIVE_HUNDRED_MILLISECONDS: 	TimeSlice.FIVE_HUNDRED_MILLISECONDS,
	TimeSlice.ONE_SECOND: 					TimeSlice.ONE_SECOND,
	TimeSlice.FIVE_SECONDS: 				TimeSlice.FIVE_SECONDS,
	TimeSlice.TEN_SECONDS: 					TimeSlice.TEN_SECONDS,
	TimeSlice.THIRTY_SECONDS: 				TimeSlice.THIRTY_SECONDS,
	TimeSlice.ONE_MINUTE: 					TimeSlice.ONE_MINUTE, 
	TimeSlice.FIVE_MINUTES: 				TimeSlice.FIVE_MINUTES,
	TimeSlice.TEN_MINUTES: 					TimeSlice.TEN_MINUTES,
	TimeSlice.THIRTY_MINUTES: 				TimeSlice.THIRTY_MINUTES,
	TimeSlice.ONE_HOUR: 					TimeSlice.ONE_HOUR
}

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Get a valid metadata key given a callable
## cannot use the str(callable) form since it contains '::'
## @param callable: Callable function to get string of
func _getMetadataKey(callable: Callable) -> String:
	var key := "callable_" + str(callable.get_object().get_instance_id()) + "_" + callable.get_method()
	return key

## Set metadata for an event
## @param callable: Callable function to get string of
## @param time_slice: Time slice to run event in
## @param recurring: Callable function to get string of
func _setEventMetadata(callable: Callable, time_slice: float, recurring: bool) -> void:
	self.set_meta(_getMetadataKey(callable), [time_slice, recurring])

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

## Check each time slice and run events if it is time
## @param delta: Time since last frame
func _process(delta: float) -> void:
	# NOTE: The upcoming loops could be combined, but it may introduce a large delay between the first event
	# and final event to be checked. Therefore I have chosen to not combine them, change with caution.
	
	# Set new time until process event for each time slice
	for time_key in _time_until_execution.keys():
		_time_until_execution[time_key] -= Clock.secondsToMilliseconds(delta)
	
	# Check if any events should occur at this time
	for time_key in _time_until_execution.keys():
		# Time not yet arrived
		if (_time_until_execution[time_key] > 0.0): continue
		
		# Process events
		var remove_key := false
		for callable in _scheduler[time_key]:
			# Invalid callable
			if (callable == null || !callable.is_valid()):
				Logger.logMsg("Attempted to call a 'Callable' that is not valid", Logger.Category.RUNTIME)
				continue
			
			# If the callable is a one-time event, remove the key when done
			# Remember metadata format: { CallableString : [TimeSlice, IsRecurringEvent] }
			if (!self.get_meta(_getMetadataKey(callable))[1]):
				remove_key = true
			
			# Call function next frame to ensure object safety
			#
			# NOTE: Possibly make a seperate function that will
			# defer it to a list that executes one function per frame,
			# rather than all at once depending on some variable like
			# singleDefer or blockDefer
			Utils.deferCallable(callable)
		
		if (remove_key):
			# Remove Time slice for one-time events
			_scheduler.erase(time_key)
			_time_until_execution.erase(time_key)
		else:
			# Reset time until next processing
			# NOTE: Uses ' = time_key' instead of ' += time_key'  to ensure 
			# consistency using a more technically time accurate formula
			# would add some micro-stutters to execution
			_time_until_execution[time_key] = time_key

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

# TODO: MAY CHANGE CALLABLE TO A VARIANT VARIABLE THAT WILL ALWAYS BE THE CLASS THAT CAN CALL SOME FUNCTION
# IT MAY BE NAMED: processTimeSliceEvents

## Add item to event scheduler to run until it is removed from the scheduler
## @param callable: Function to call
## @param time_slice: Which time slice to add it in | NOTE: Time Slice MUST be a predefined slice
func pushRecurringEvent(callable: Callable, time_slice: int) -> void:
	# User inputted invalid time slice
	if (time_slice not in _time_until_execution):
		Logger.logMsg("Cannot set reccurring event. Please use a valid Time Slice.", Logger.Category.ERROR)
		return
	
	_scheduler[time_slice].push_back(callable)
	_setEventMetadata(callable, time_slice, true)

## Add item to event scheduler to run ONE time
## @param callable: Function to call
## @param time_slice: When to run event (in milliseconds) | NOTE: Time Slice can be ANY number of time
func pushOneTimeEvent(callable: Callable, time_slice: int) -> void:
	if (!_scheduler.has(time_slice)):
		_scheduler[time_slice] = []
	_scheduler[time_slice].push_back(callable)
	if (!_time_until_execution.has(time_slice)):
		_time_until_execution[time_slice] = time_slice
	_setEventMetadata(callable, time_slice, false)

## Remove item from event scheduler
## @param callable: Callable function to remove
func erase(callable: Callable) -> void:
	var callable_str := _getMetadataKey(callable)
	if (!self.has_meta(callable_str)):
		Logger.logMsg("Callable [" + callable_str + "] does not exist in scheduler", Logger.Category.ERROR)
		return
	
	var time_slice = self.get_meta(callable_str)
	_scheduler[time_slice].erase(callable)

## Check if a callable exists in the event scheduler
## @param callable: Callable function to check
func exists(callable: Callable) -> bool:
	var callable_str := _getMetadataKey(callable)
	if (self.has_meta(callable_str)):
		return true
	else:
		return false

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
