extends Control

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

# Window Size
@onready var viewport := get_viewport()
@onready var window := viewport.get_window()
var _window_size := Vector2i(1920, 1080) # Used instead of window.size to avoid unnecessary function calls


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

## Set new size of the window
## new_size: New size of the window
func setWindowSize(new_window_size: Vector2i) -> void:
	window.size = new_window_size

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
