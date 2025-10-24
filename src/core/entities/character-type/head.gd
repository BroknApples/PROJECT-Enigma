extends Node3D

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Head
## 
## Head of a character type
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

@onready var _character_body := $".".get_parent()
@onready var _camera := $"PlayerCamera"
@onready var _weapons := $"Weapons"

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
	if (!_character_body._initialized):
		set_process_mode(Node.PROCESS_MODE_DISABLED)
		await _character_body.SIG_initialized
	set_process_mode(Node.PROCESS_MODE_ALWAYS)

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Get the camera for this head
## @returns PlayerCamera: The player camera for this head
func getCameraNode() -> PlayerCamera:
	return _camera

## Get the weapons list node for this head
## @returns Node3D: Node the weapons are listed in
func getWeaponsNode() -> Node3D:
	return _weapons

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
