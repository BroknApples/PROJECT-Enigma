extends Node

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Entry point for the Server Application
## 
## Holds application data and cross-checks with clients to ensure
## they are running the latest version
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

@onready var play_button := $"Play Button"

var multiplayer_peer: ENetMultiplayerPeer
var connected_profiles := {} # { PeerID : ProfileID } { int : int } | TODO: { int : Profile }

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

## Start server button pressed
func _on_play_button_pressed() -> void:
	# Cannot start server multiple times so disable button
	play_button.disabled = true
	
	# Start server
	_startServer()

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# TESTING
	Settings.setWindowSize(Vector2i(1760, 990))
	Logger.logMsg("Resized Window: " + str(Settings.getWindowSize()), Logger.Category.DEBUG)
	Settings.window.position += Vector2i(80, 60)
	# TESTING
	
	# Ensure signals are connected
	play_button.pressed.connect(Callable(self, "_on_play_button_pressed"))

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Start game server
func _startServer() -> void:
	# Ensure Developer did not input an invalid port number or maximum clients variable
	if (GameData.SERVER_PORT_NUMBER > GameData.SERVER_MAXIMUM_PORT_NUMBER):
		Logger.logMsg("Port number out of range (0-" + str(GameData.SERVER_MAXIMUM_PORT_NUMBER) + ").", Logger.Category.ERROR)
		return
	if (GameData.SERVER_MAX_CLIENTS > GameData.SERVER_MAXIMUM_MAX_CLIENTS):
		Logger.logMsg("Maximum Clients out of range (0-" + str(GameData.SERVER_MAXIMUM_MAX_CLIENTS) + ").", Logger.Category.ERROR)
		return
	
	# Create server
	multiplayer_peer = ENetMultiplayerPeer.new()
	var result = multiplayer_peer.create_server(GameData.SERVER_PORT_NUMBER, GameData.SERVER_MAX_CLIENTS)
	
	# Error creating server
	if (result != OK):
		Logger.logMsg("Could not start server.", Logger.Category.ERROR)
		return # Early exit due to error
	
	multiplayer.multiplayer_peer = multiplayer_peer
	self.set_multiplayer_authority(Utils.SERVER_RPC_ID)
	multiplayer.peer_connected.connect(Callable(self, "onPeerConnected"))
	multiplayer.peer_disconnected.connect(Callable(self, "onPeerDisconnected"))
	Logger.logMsg("Server started.", Logger.Category.RUNTIME)

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

@rpc("any_peer", "call_local", "reliable")
func recieveProfileId(profile_id: int) -> void:
	var peer_id := multiplayer.get_remote_sender_id()
	connected_profiles[peer_id] = profile_id
	Logger.logMsg("Received profile ID from peer %d: %s" % [peer_id, profile_id], Logger.Category.RUNTIME)
	print("Received profile ID from peer %d: %s" % [peer_id, profile_id])

	# Confirm server recieved connection to client
	confirmProfileRecieved.rpc_id(peer_id, profile_id)

@rpc("authority", "call_local", "reliable")
func confirmProfileRecieved(recieved_id: int) -> void: pass

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
