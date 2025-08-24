extends Node

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

@onready var temp_node_3d := $TempNode3D ## Node where i can temporarily reparent things to, while keeping them invisible

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
	# Close game properly
	if (what == NOTIFICATION_WM_CLOSE_REQUEST):
		Utils.exitGame()
	# TODO: Hold some variable that decides if it will be captured or cursor mode when focusing in
	# Set mouse mode to captured when the game enters focus
	elif (what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Set mouse mode to cursor when game exits focus
	elif (what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

## Call a deferred function that loads the game up
func _ready() -> void:
	temp_node_3d.visible = false
	
	# Set the game root to this node
	Utils.GAME_ROOT = self
	
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
	var lobby_scene = AssetManager.getAsset(AssetManager.Assets.LOBBY_SCENE)
	if (lobby_scene == null):
		Logger.logMsg("Error loading scene: 'LobbyScene'", Logger.Category.ERROR)
	
	# After loading everything, change the scene to the lobby scene
	self.add_child(lobby_scene.instantiate())

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
