extends Node

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## CommandLineArguments Singleton
## 
## Gets the command line arguments passed to a game instance
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

## All keys of valid command line arguments
class Keys:
	const PERMISSON_LEVEL: StringName = &"PermissionLevel"
	const INSTANCE_NUMBER: StringName = &"InstanceNumber"
	const BUILD_TYPE: StringName = &"BuildType"

## Specifies possible build types
class BuildTypes:
	const RELEASE = "Release"
	const DEVELOPMENT = "Development"

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

var command_line_args: Dictionary

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Parse command line args into a dictionary
func _parseCommandLineArgs() -> void:
	for argument in OS.get_cmdline_args():
		# Parse valid command-line arguments into a dictionary
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			command_line_args[key_value[0].lstrip("--")] = key_value[1]
			
# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

## Parse command line args on startup
func _ready() -> void:
	_parseCommandLineArgs()
	
# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Get all of the command line args passed to the game
func getCommandLineArguments() -> Dictionary:
	return command_line_args

## Get a specific command line argument given a key
func getKey(string: String) -> String:
	return command_line_args.get(string, "")
	
# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
