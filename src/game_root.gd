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

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

## Exit requested
func _notification(what: int) -> void:
	if (what == NOTIFICATION_WM_CLOSE_REQUEST):
		Utils.exitGame()

## Call a deferred function that loads the game up
func _ready() -> void:
	# TESTING
	Settings.setWindowSize(Vector2i(1280, 720))
	# TESTING
	
	call_deferred("loadGame")

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Load the game up. Loads assets then finally swaps scene to the lobby
func loadGame() -> void:
	# TODO: Need to add another thread that will show the loading percent for assets
	AssetManager.loadAssetGroup(AssetManager.AssetGroups.STARTUP)
	var lobby_scene = AssetManager.getAsset(AssetManager.Assets.LobbyScene[0])
	if (lobby_scene == null):
		Logger.logMsg("Error loading scene: 'LobbyScene'", Logger.Category.ERROR)
	
	# After loading everything, change the scene to the lobby scene
	self.add_child(lobby_scene.instantiate())

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
