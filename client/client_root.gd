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
const IP_ADDRESS: String = "127.0.0.1" # TODO: Instead change to list of server ip address, keep trying until one works
const PORT_NUMBER: int = 54562 # Server listening port

var multiplayer_peer: ENetMultiplayerPeer
var connected_to_server := false # Are we currently connected to the server

# TESTING
var profile_id = 1 # TODO: Change this to a Profile Class type and ensure uniqueness or whatever

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

func _on_connected_to_server() -> void:
	Logger.logMsg("Connected to server with IP: " + IP_ADDRESS, Logger.Category.RUNTIME)
	rpc_id(Utils.SERVER_RPC_ID, "recieveProfileId", profile_id)
	connected_to_server = true

func _on_server_connection_failed() -> void:
	Logger.logMsg("Disconnected from server with IP: " + IP_ADDRESS, Logger.Category.RUNTIME)
	connected_to_server = false

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

## Exit requested
func _notification(what: int) -> void:
	if (what == NOTIFICATION_WM_CLOSE_REQUEST):
		Utils.exitGame()

func _ready() -> void:
	# TESTING
	Settings.setWindowSize(Vector2i(1760, 990))
	Logger.logMsg("Resized Window: " + str(Settings.getWindowSize()), Logger.Category.DEBUG)
	Settings.window.position += Vector2i(80, 60)
	# TESTING
	
	# Initially connect to server
	if !(_connectToServer(IP_ADDRESS, PORT_NUMBER)):
		Logger.logMsg("Could not open network connection.", Logger.Category.ERROR)
		Utils.exitGame()

func _process(delta: float) -> void:
	# If the node is not connected to the server, then connect it
	if (!connected_to_server):
		Logger.logMsg("Reconnecting...", Logger.Category.RUNTIME)

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

@rpc("any_peer", "call_local", "reliable") func recieveProfileId(recieved_id: int) -> void: pass

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
