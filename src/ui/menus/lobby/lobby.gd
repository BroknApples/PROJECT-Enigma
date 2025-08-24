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
	$"ConnectToHost Panel".visible = false
	$HostGamePanelContainer.visible = true
	P2PNetworking.becomeHost()
	P2PNetworking.openServerToPeers()

## Start the actual game
func _on_start_game_button_pressed() -> void:
	startGame("res://src/testing/test_world/test_world.tscn")

## Stop the host session
func _on_stop_hosting_game_button_pressed() -> void:
	$"ConnectToHost Panel".visible = false
	$HostGamePanelContainer.visible = false
	P2PNetworking.closeNetworking()

## Open gui for joining a game
func _on_join_button_pressed() -> void:
	# TESTING: Attempt to connect to the first address found
	P2PNetworking.listenForLANHosts()
	
	await P2PNetworking.SIG_host_peer_detected
	if (P2PNetworking.getKnownHosts().size() > 0):
		$"ConnectToHost Panel".visible = true
		P2PNetworking.connectToHost(P2PNetworking.getKnownHosts()[0])
	
	# Invalid connection, so quit the lobby or something
	if (!await P2PNetworking.validateConnection()):
		pass
		# TODO: idk do something here

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

@rpc("any_peer", "call_local", "reliable")
func _setupGame(world_file_path: String, player_list: Dictionary) -> void:
	# Ensure the client is not listening for any more hosts since the game has started
	if (P2PNetworking.isListeningForHosts()):
		P2PNetworking.stopListeningForHosts()
	
	_selected_world = load(world_file_path)
	
	var world_instance = _selected_world.instantiate()
	Utils.GAME_ROOT.add_child(world_instance)
	
	# Remove the lobby scene from the tree
	self.queue_free()
	
	# The server is responsible for spawning the players
	if (P2PNetworking.isServer()):
		# Add the players:
		for peer_id in player_list.keys():
			world_instance.addPlayer(peer_id)

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	pass

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

func startGame(world_file_path: String) -> void:
	# Only allow the startGame button to work if you are the host
	if (P2PNetworking.getLocalPeerID() != P2PNetworking.HOST_PEER_ID):
		return
	
	# Stop broadcasting that the server is open to
	# peers since the game is starting now
	P2PNetworking.stopBroadcastingToPeers()
	
	# Dictionary for player characters
	# NOTE -> Format:
	# { PEER_ID : PlayerCharacterType }
	var player_list := {}
	
	# Get peers
	var peers := multiplayer.get_peers()
	# NOTE: (P2PNetworking.getLocalPeerID() - 1) should equal 0
	peers.insert(P2PNetworking.getLocalPeerID() - 1, P2PNetworking.getLocalPeerID())
	
	# Setup player list
	for peer_id in peers:
		# TODO: Get the actual data for a player character from each peer,
		# ASSIGN THE STATS DATA HERE IN THE LIST, THEN PASS IT AND ASSIGN IT ON EACH CLIENT
		# SOMETHING LIKE: player_list[peer_id] = player_data
		player_list[peer_id] = null
	
	# Setup the actual game data
	# TODO: Get players
	# TODO: Need to add stuff like enemy list or whatever else here
	_setupGame.rpc(world_file_path, player_list)

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
