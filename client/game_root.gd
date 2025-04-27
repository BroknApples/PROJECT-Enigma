extends Control

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Entry point for the Client Application
## 
## Holds application data and ensures version is up-to-date
##
## TODO: GameRoot will hold ALL of the data like, what game session id is the player
## currently in, is the player connected to the server, etc.
## Will function similarly to a global script
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

## Defines variables used when a player is disconnected from the server
class DisconnectedState:
	## When should the server stop attempting to reconnect to the server in milliseconds
	const MAX_DISCONNECTED_TIME = 10_000 # 10 seconds
	
	var disconnected_time := 0
	var previous_print_time := 0

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

const GAME_VERSION: String = "alpha v1.0.0"

var multiplayer_peer: ENetMultiplayerPeer
var disconnected_state := DisconnectedState.new()
var connected_to_server := false # Are we currently connected to the server

# TESTING/
var profile_id = 1 # TODO: Change this to a Profile Class type and ensure uniqueness or whatever
# /TESTING

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

func _on_connected_to_server() -> void:
	Logger.logMsg("Connected to server with IP: " + GameData.SERVER_IP_ADDRESS, Logger.Category.RUNTIME)
	recieveProfileId.rpc_id(GameData.SERVER_RPC_ID, profile_id)
	
	# Set the game state to connected
	connected_to_server = true
	disconnected_state = null

func _on_server_connection_failed() -> void:
	Logger.logMsg("Disconnected from server with IP: " + GameData.SERVER_IP_ADDRESS, Logger.Category.RUNTIME)
	
	# Set the game state to disconnected
	connected_to_server = false
	disconnected_state = DisconnectedState.new()

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# TESTING/
	Settings.setWindowSize(Vector2i(1760, 990))
	Logger.logMsg("Resized Window: " + str(Settings.getWindowSize()), Logger.Category.DEBUG)
	Settings.window.position += Vector2i(80, 60)
	# /TESTING
	
	# Initially connect to server
	if !(_connectToServer(GameData.SERVER_IP_ADDRESS, GameData.SERVER_PORT_NUMBER)):
		Logger.logMsg("Could not open network connection.", Logger.Category.ERROR)
		Utils.exitGame()

func _process(delta: float) -> void:
	# If the node is not connected to the server, then connect it
	if (!connected_to_server):
		disconnected_state.disconnected_time += delta
		if (disconnected_state.disconnected_time >= disconnected_state.MAX_DISCONNECTED_TIME):
			# TESTING/
			# TODO: Make this show some other screen, for now just simply quit the game
			Utils.exitGame()
			# /TESTING
		# else:
		Logger.logMsg("Reconnecting to [%s]..." % [GameData.SERVER_IP_ADDRESS], Logger.Category.RUNTIME)

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

func _connectToServer(ip_address: String, port: int) -> bool:
	# Attempt to add client to server
	multiplayer_peer = ENetMultiplayerPeer.new()
	var result = multiplayer_peer.create_client(ip_address, port)
	
	# Error attempting to add client to server
	if (result != OK):
		Logger.logMsg("Could not connect to dedicated server.", Logger.Category.RUNTIME)
		multiplayer_peer.close()
		return false
	
	# Connect to server
	multiplayer.multiplayer_peer = multiplayer_peer
	multiplayer.connected_to_server.connect(Callable(self, "_on_connected_to_server"))
	multiplayer.connection_failed.connect(Callable(self, "_on_server_connection_failed"))
	
	return true

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

@rpc("authority", "call_local", "reliable")
func confirmProfileRecieved(received_id: int):
	Logger.logMsg("Server confirmed it received profile ID: " + str(received_id), Logger.Category.RUNTIME)
	print("Server confirmed it received profile ID: " + str(received_id))

@rpc("any_peer", "call_local", "reliable")
func recieveProfileId(recieved_id: int) -> void: pass

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
