extends Node

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Logger Singleton
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
	NETWORK,
}

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

const _RELEASE_LOG_FILE_PATH: StringName = &"user://logs"  ## Log file's folder used in release builds
const _DEVELOPMENT_LOG_FILE_PATH: StringName = &"res://test-logs" ## Log file's folder used in development builds
const _LOG_FILE_BASENAME: StringName = &"log" ## Basename of the log file
const _LOG_FILE_EXTENSION: StringName = &".txt" ## File extension of the log file
var _log_file_path: String = "" ## Actual path used in the program

## Queued data to be printed to the terminal
var _terminal_buffer: Array[String] = []

## Queued data to be printed to the log file
var _file_buffer: Array[String] = []

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
		Category.NETWORK:
			return "[NETWORK]"
		_: # Default
			return "[LOGGER]"

## Get a message in the proper format
## @param msg: String to format
## @param category: Category to preface with
func _getFormattedMsg(msg: String, category: Category) -> String:
	const CATEGORY_HEADER_WHITESPACE: int = 11 # Whitespace areound category
	
	var formatted_msg := Clock.TimePoint.new().getTimeString(true)
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
	Utils.writeToFile(_log_file_path, msg, true)

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# Get log file path from cmd line arguments
	if (LaunchOptions.getKey(LaunchOptions.Keys.BUILD_TYPE) == LaunchOptions.BuildTypes.RELEASE):
		# Release build, so use real log file path
		_log_file_path = _RELEASE_LOG_FILE_PATH + "/" + _LOG_FILE_BASENAME + LaunchOptions.getKey(LaunchOptions.Keys.INSTANCE_NUMBER)
		
		# If the log file folder doesn't exist, create it
		if (!DirAccess.dir_exists_absolute(_RELEASE_LOG_FILE_PATH)):
			DirAccess.make_dir_recursive_absolute(_RELEASE_LOG_FILE_PATH)
	elif (LaunchOptions.getKey(LaunchOptions.Keys.BUILD_TYPE) == LaunchOptions.BuildTypes.DEVELOPMENT):
		# Development build, so use in-codebase log file path
		_log_file_path = _DEVELOPMENT_LOG_FILE_PATH + "/" + _LOG_FILE_BASENAME + LaunchOptions.getKey(LaunchOptions.Keys.INSTANCE_NUMBER)
		
		# If the log file folder doesn't exist, create it
		if (!DirAccess.dir_exists_absolute(_DEVELOPMENT_LOG_FILE_PATH)):
			DirAccess.make_dir_recursive_absolute(_DEVELOPMENT_LOG_FILE_PATH)
	
	# Add file extension to path (.txt)
	_log_file_path += _LOG_FILE_EXTENSION
	
	# Rest log files before logging
	clearLogFiles()
	
	# Flush both buffers every 5 seconds
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
	_terminal_buffer.push_back(formatted_msg)

## Adds msg to file log queue
## @param msg: Message to print
## @param category: Category to print it in
# TODO: Eventually make it so it writes in the specific category in the log file every 10 seconds.
# going to have to use a _process function with the utils.gd EventScheduler variable
func logToFile(msg: String, category: Category) -> void:
	# Print to file with format:
	# <<timestamp>:> <category> <message>
	var formatted_msg = _getFormattedMsg(msg, category)
	_file_buffer.push_back(formatted_msg)

## NOTE: Typically only called by the EventScheduler
## Flushes both the terminal and file buffer
func flushBuffers() -> void:
	flushTerminalBuffer()
	flushFileBuffer()

## NOTE: Typically only called by the EventScheduler
## Print everything in the terminal buffer
func flushTerminalBuffer() -> void:
	var terminal_str := ""
	while !_terminal_buffer.is_empty():
		terminal_str += _terminal_buffer.pop_front()
		terminal_str += '\n'
		
	# Remove last char because stdout adds a newline, so the
	# last character would make it print two newlines
	var str_len = terminal_str.length()
	terminal_str = terminal_str.substr(0, str_len - 1)
	
	# Only print when a string exists
	if (str_len > 0):
		_logToTerminal(terminal_str)

## NOTE: Typically only called by the EventScheduler
## Write everything in the file buffer
func flushFileBuffer() -> void:
	var file_str := ""
	while !_file_buffer.is_empty():
		file_str += _file_buffer.pop_front()
		file_str += '\n'
	
	var str_len = file_str.length()
	
	# Only print when a string exists
	if (str_len > 0):
		_logToFile(file_str)

## Reset the log file by overwriting it with an empty string
func clearLogFiles() -> void:
	Utils.writeToFile(_log_file_path, "")

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
