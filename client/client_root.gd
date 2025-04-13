extends Control

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Entry point for the Client Application
## 
## Holds application data and ensures version is up-to-date
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

const VERSION: String = "alpha v1.0.0"

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	Logger.logMsg("Resized Window: " + str(Settings.getWindowSize()), Logger.Category.DEBUG)
	Settings.setWindowSize(Vector2i(1760, 990))
	Settings.window.position += Vector2i(80, 60) # TESTING

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
