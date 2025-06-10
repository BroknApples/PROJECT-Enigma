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
	const ESCAPE				: StringName = &"Escape"
	const MOVE_FORWARD			: StringName = &"Move Forward"
	const MOVE_LEFT				: StringName = &"Move Left"
	const MOVE_BACKWARD			: StringName = &"Move Backward"
	const MOVE_RIGHT			: StringName = &"Move Right"
	const JUMP					: StringName = &"Jump"
	const SPRINT				: StringName = &"Sprint"
	const CROUCH				: StringName = &"Crouch"
	const CHANGE_CAMERA_POV		: StringName = &"Change Camera POV"

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
