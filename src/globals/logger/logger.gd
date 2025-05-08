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

## Queued data to be printed to the terminal
var terminal_buffer: Array[String] = []

## Queued data to be printed to the log file
var file_buffer: Array[String] = []

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

## Get a message in the proper format
## @param msg: String to format
## @param category: Category to preface with
func _getFormattedMsg(msg: String, category: Category) -> String:
	const CATEGORY_HEADER_WHITESPACE: int = 11 # Whitespace areound category
	
	var formatted_msg := Utils.TimePoint.new().getTimeString(true)
	var category_str := _getCategoryHeader(category)
	formatted_msg += category_str
	formatted_msg += " ".repeat(CATEGORY_HEADER_WHITESPACE - category_str.length())
	formatted_msg += msg
	
	return formatted_msg

## Write log message ONLY in the terminal
## @param msg: Message to print
func _logToTerminal(msg: String) -> void:
	print(msg)

## Write log message ONLY in the log file
## @param msg: Message to print
func _logToFile(msg: String) -> void:
	# TODO: Implement
	pass

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# Flush buffers every 5 seconds
	EventScheduler.pushRecurringEvent(Callable(self, "flushBuffers"), EventScheduler.TimeSlice.FIVE_SECONDS)

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Adds msg to terminal AND file log queue
## @param msg: Message to print
## @param category: Category to print it in
func logMsg(msg: String, category: Category) -> void:
	logToTerminal(msg, category)
	logToFile(msg, category)

## Adds msg to terminal log queue
## @param msg: Message to print
## @param category: Category to print it in
func logToTerminal(msg: String, category: Category) -> void:
	# Print to terminal with format:
	# <<timestamp>:> <category> <message>
	var formatted_msg = _getFormattedMsg(msg, category)
	terminal_buffer.push_back(formatted_msg)

## Adds msg to file log queue
## @param msg: Message to print
## @param category: Category to print it in
# TODO: Eventually make it so it writes in the specific category in the log file every 10 seconds.
# going to have to use a _process function with the utils.gd EventScheduler variable
func logToFile(msg: String, category: Category) -> void:
	# Print to file with format:
	# <<timestamp>:> <category> <message>
	var formatted_msg = _getFormattedMsg(msg, category)
	file_buffer.push_back(formatted_msg)

## NOTE: Typically only called by the EventScheduler
## Flushes both the terminal and file buffer
func flushBuffers() -> void:
	flushTerminalBuffer()
	flushFileBuffer()

## NOTE: Typically only called by the EventScheduler
## Print everything in the terminal buffer
func flushTerminalBuffer() -> void:
	var terminal_str := ""
	while !terminal_buffer.is_empty():
		terminal_str += terminal_buffer.pop_front()
		terminal_str += '\n'
	_logToTerminal(terminal_str)

## NOTE: Typically only called by the EventScheduler
## Write everything in the file buffer
func flushFileBuffer() -> void:
	var file_str := ""
	while !file_buffer.is_empty():
		file_str += file_buffer.pop_front()
		file_str += '\n'
	_logToFile(file_str)

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
