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

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

## Open gui for hosting a game
func _on_host_button_pressed() -> void:
	P2PNetworking.becomeHost()
	P2PNetworking.openServerToPeers()
	await Utils.sleep(6.0)
	P2PNetworking.stopBroadcastingToPeers()

## Open gui for joining a game
func _on_join_button_pressed() -> void:
	P2PNetworking.listenForLANHosts()
	await Utils.sleep(5.0)
	
	# TESTING: Attempt to connect to the first address found
	P2PNetworking.connectToHost(P2PNetworking.getKnownHosts()[0])
	await Utils.sleep(1.4)
	await P2PNetworking.validateConnection()
		# Invalid connection, so quit or something
		

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

func _ready() -> void:
	pass

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
