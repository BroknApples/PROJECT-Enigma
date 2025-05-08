extends Control

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## GameRoot
## 
## Entry point of the game, load assets and stuff
## TODO: Possibly check version to confirm you have updated to
## the latest release
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

const LOBBY_SCENE_PATH: String = "res://src/lobby_scene/lobby.tscn"

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

## Call a deferred function that loads the game up
func _ready() -> void:
	call_deferred("loadGame")

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Load the game up. Loads assets then finally swaps scene to the lobby
func loadGame() -> void:
	AssetManager.loadAssets()
	get_tree().change_scene_to_file(LOBBY_SCENE_PATH)

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
