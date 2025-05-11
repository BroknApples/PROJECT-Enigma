extends Control

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Settings Singleton
## 
## Defines settings specific to the user
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

# Window Size
@onready var viewport := get_viewport()
@onready var window := viewport.get_window()

# Used instead of window.size to avoid unnecessary function calls
# when attempting to get the size of the window
var _window_size := Vector2i(1920, 1080)


# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

func _on_window_size_changed() -> void:
	_window_size = window.get_size_with_decorations()

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	viewport.connect("size_changed", _on_window_size_changed)

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Get the current window_size of the application
func getWindowSize() -> Vector2i:
	return _window_size

## Set new size of the window and center it on the monitor
## new_size: New size of the window
func setWindowSize(new_window_size: Vector2i) -> void:
	window.size = new_window_size
	var monitor_size := DisplayServer.screen_get_size()
	
	# idk why it's divided by 6, it just works though
	# thought it would be like 4 or 2
	window.position += (monitor_size / 6)

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
