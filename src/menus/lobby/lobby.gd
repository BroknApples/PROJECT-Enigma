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

## Open gui for hosting a game
func _on_host_button_pressed() -> void:
	# TESTING
	P2PNetworking.becomeHost()
	P2PNetworking.openServerToPeers()
	await Utils.sleep(0.0)
	P2PNetworking.stopBroadcastingToPeers()
	
	startGame.rpc("res://src/testing/test_world/test_world.tscn")
	# TESTING

## Open gui for joining a game
func _on_join_button_pressed() -> void:
	# TESTING: Attempt to connect to the first address found
	P2PNetworking.listenForLANHosts()
	await Utils.sleep(3.0)
	
	if (P2PNetworking.getKnownHosts().size() > 0):
		P2PNetworking.connectToHost(P2PNetworking.getKnownHosts()[0])
	await Utils.sleep(1.0)
	
	# Invalid connection, so quit the lobby or something
	if (!await P2PNetworking.validateConnection()):
		pass
	
	# will immediately start game for testing
	
	
	# TESTING

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	pass

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

@rpc ("authority", "reliable", "call_local")
func startGame(world_file_path: String) -> void:
	# TESTING
	_selected_world = load(world_file_path)
	
	var instance = _selected_world.instantiate()
	Utils.GAME_ROOT.add_child(instance)
	
	self.queue_free()

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
