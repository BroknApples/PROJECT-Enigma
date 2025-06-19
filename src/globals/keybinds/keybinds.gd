extends Node

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Keybinds Singleton
## 
## Defines all inputs used in the game
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

## ActionNames Class
## All input action names
class ActionNames:
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

## Which actions are not allowed to be modified in the settings
const immodifiable: Array[StringName] = [
	ActionNames.ESCAPE
]

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

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
