extends Node

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## InputBinder Singleton
## 
## Defines all actions & binding of said actions used in the game
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

## Actions Class
## All input action names
class Actions:
	# MISC
	const ESCAPE				: StringName = &"Escape"
	const CHANGE_CAMERA_POV		: StringName = &"Change Camera POV"
	
	# MOVEMENT
	const MOVE_FORWARD			: StringName = &"Move Forward"
	const MOVE_LEFT				: StringName = &"Move Left"
	const MOVE_BACKWARD			: StringName = &"Move Backward"
	const MOVE_RIGHT			: StringName = &"Move Right"
	const JUMP					: StringName = &"Jump"
	const SPRINT				: StringName = &"Sprint"
	const CROUCH				: StringName = &"Crouch"
	
	# WEAPON USAGE
	const PRIMARY_ATTACK		: StringName = &"Primary Attack"
	const SECONDARY_ATTACK		: StringName = &"Secondary Attack"
	const QUICK_MELEE			: StringName = &"Quick Melee"
	const SWAP_TO_WEAPON_ONE	: StringName = &"Swap to Weapon 1"
	const SWAP_TO_WEAPON_TWO	: StringName = &"Swap to Weapon 2"
	const SWAP_TO_MELEE_WEAPON	: StringName = &"Swap to Melee Weapon"
	const NEXT_WEAPON			: StringName = &"Next Weapon"
	const PREVIOUS_WEAPON		: StringName = &"Previous Weapon"

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

## Which actions are not allowed to be modified in the settings
const IMMODIFIABLE: Array[StringName] = [
	Actions.ESCAPE
]

var hooks: Dictionary = {} # { StringName : Array[Callable] }
var binds: Dictionary = {} # { KeyCode : StringName }

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# Load saved data if it exists
	loadKeybinds()

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

func registerActionCallback(action_name: StringName, callback: Callable) -> void:
	pass

func deregisterActionCallback(action_name: StringName, callback: Callable) -> void:
	pass

func setKeysToAction(action_name: StringName, keys: Array[int]) -> void:
	pass

func loadKeybinds() -> void:
	const BINDS_SAVE_PATH = "user://saved_keybinds.json"

func saveKeybinds() -> void:
	const BINDS_SAVE_PATH = "user://saved_keybinds.json"

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
