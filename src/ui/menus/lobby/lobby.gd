extends Control

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Lobby
## 
## Implements functions the lobby menu needs to function
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

var _selected_world: PackedScene

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

## Start the actual game
func _on_start_game_button_pressed() -> void:
	startGame("res://src/testing/test_world/test_world.tscn")

## Stop the host session
func _on_stop_hosting_game_button_pressed() -> void:
	$"ConnectToHost Panel".visible = false
	$HostGamePanelContainer.visible = false

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

func startGame(world_file_path: String) -> void:
	# Setup the actual game data
	# TODO: Get players
	# TODO: Need to add stuff like enemy list or whatever else here
	_selected_world = load(world_file_path)
	
	var world_instance = _selected_world.instantiate()
	Utils.GAME_ROOT.add_child(world_instance)
	
	# Remove the lobby scene from the tree
	self.queue_free()
	
	# Add the players:
	world_instance.addPlayer()

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
