extends Node

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Logger
## 
## Log data in a nice format to the terminal, file, or both
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

enum Category {
	ERROR,
	DEBUG,
	RUNTIME,
}

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

const LOG_FILE_PATH: String = "user://logs/log.txt"

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Get a header for a given logging category
## @param category: Logger category to get string format of
func _getCategoryHeader(category: Category) -> String:
	match(category):
		Category.ERROR:
			return "[ERROR]"
		Category.DEBUG:
			return "[DEBUG]"
		Category.RUNTIME:
			return "[RUNTIME]"
		_: # Default
			return "[LOGGER]"

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Log some data to the terminal AND the log file
func logMsg(msg: String, category: Category) -> void:
	logToTerminal(msg, category)
	logToFile(msg, category)

## Write log message ONLY in the terminal
func logToTerminal(msg: String, category: Category) -> void:
	# Print to terminal with format:
	# <timestamp> <category> <message>
	# TODO: Get current runtime as well
	var formatted_msg := _getCategoryHeader(category) + " " + msg
	print(formatted_msg)

## Write log message ONLY in the log file
## @param msg: Message to print
## @param category: Category to print it in
## @param timestamp_whitespace: How much whitespace in the the timestamp section of the message
# TODO: Eventually make it so it writes in the specific category in the log file every 10 seconds.
# going to have to use a _process function with the utils.gd EventScheduler variable
func logToFile(msg: String, category: Category, timestamp_whitespace: int = 5) -> void:
	# Print to file with format:
	# <category>
	# <timestamp> <some whitespace> | <message>
	# ...
	# ...
	# <category>
	
	# TODO: Implement
	print("logging to file.")
	
# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
