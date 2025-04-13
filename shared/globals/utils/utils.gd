extends Node

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## 
## 
## 
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

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

## Get the current runtime of the program in milliseconds
func getRuntime() -> int:
	return Time.get_ticks_msec()

## Get the current runtime of the program in string format
func getRuntimeString() -> String:
	# TODO: Format in an HH:MM:SS:MS way
	return str(getRuntime())

## Run a callable the next frame to ensure object safety
## @param callable: Function to be deferred
func deferCallable(callable: Callable) -> void:
	await get_tree().process_frame
	callable.call()

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
