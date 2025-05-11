extends Node

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## P2PNetworking
##
## Sets up networking based on a p2p connection
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

## Defines enumes for different server accessibility types
enum ServerAccessiblity {
	CLOSED, ## No one else can join
	PRIVATE, ## Only those with the code can join
	FRIENDS_ONLY, ## Friends can freely join
	PUBLIC, ## Anyone can freely join
}

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

## Emitted when validating a client's connection to a host
signal SIG_server_handshake(valid: bool)

# General Networking
var _known_host_peers: Array[String] = [] ## Known clients acting as hosts
var _host := false ## Is the current client the host
var _listening_for_lan_host_peers := false ## Is the current client listening for peers over LAN
var _listening_for_nat_host_peers := false ## Is the current client listening for peers over NAT
var _broadcasting_server_to_peers := false ## Is the current client a host that is broadcasting its server connection
var _server_accessibility := ServerAccessiblity.CLOSED ## Accesibility of the client if its a server (closed by default)

# UDP Connection Making
const _LAN_SUBNET: StringName = &"255.255.255.255" ## Local Area Network Subnet Mask
const _LAN_IP_ADDRESSES: StringName = &"*" ## Both IPv4 & IPv6 IP Address used for LAN connections
const _LAN_IPV4_ADDRESSES: StringName = &"0.0.0.0" ## IPv4 Address used for LAN connections
const _LAN_IPV6_ADDRESSES: StringName = &"::" ## IPv6 Address used for LAN connections
const _LAN_PEER_DISCOVERY_PORT_NUMBER: int = 35760 ## Port number to discover peer connections on
const _HOST_PEER_BROADCAST_MESSAGE: StringName = &"P2P_HOST_SERVER_OPEN" ## String broadcasted to validate host client connections
var _udp_socket: PacketPeerUDP = null ## UDP connection listener

# ENet Networking
const _SERVER_RPC_ID: int = 1 ## RPC ID of the server
const _MULTIPLAYER_ENET_PORT_NUMBER: int = 35759 ## Port number to pass data through
const _MULTIPLAYER_ENET_MAX_CLIENTS: int = 4 ## Maximum number of clients that can connect to a single server
var _multiplayer_enet: ENetMultiplayerPeer = null ## Multiplayer ENet

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Broadcast a packet that tells clients they wish to accept connections
func _broadcastServerConnection() -> void:
	const BROADCAST_INTERVAL: float = 2.0 ## Seconds between each broadcast
	var count := 0
	
	while (_host && _broadcasting_server_to_peers):
		# Broadcast on local network
		var lan_err := _udp_socket.set_dest_address(_LAN_SUBNET, _LAN_PEER_DISCOVERY_PORT_NUMBER)
		if (lan_err != OK):
			Logger.logMsg("Could not broadcast on local network.", Logger.Category.NETWORK)
		else:
			Logger.logMsg("Broadcasting peer discovery packet [%s]." % [count], Logger.Category.NETWORK)
			_udp_socket.put_packet(_HOST_PEER_BROADCAST_MESSAGE.to_utf8_buffer())
		
		count += 1
		await Utils.sleep(BROADCAST_INTERVAL) ## Broadcast after each time interval


## Used to validate peer connections to the host server.
## Called by the client
## @param user_profile: Profile of the newly connected user
@rpc ("any_peer", "call_remote", "reliable")
func _clientToServerHandshake(user_profile: UserProfile) -> void:
	# TODO: List some actual profile data in this log message
	Logger.logMsg("Server recieved new connection: <>", Logger.Category.NETWORK)
	Callable(_serverToClientHandshake).rpc(user_profile)

## Used to validate peer connections to the host server.
## Called by the server host
## @param user_profile: Profile of the newly connected user
@rpc ("authority", "call_remote", "reliable")
func _serverToClientHandshake(user_profile: UserProfile) -> void:
	# TODO: List some actual profile data in these log messages
	
	# TODO: Actually compare the recieved user profile data with your local data
	# to see if it thinks you are the correct account
	if (user_profile is not UserProfile):
		Logger.logMsg("Server recieved invalid UserProfile.", Logger.Category.ERROR)
		SIG_server_handshake.emit(false)
	else:
		Logger.logMsg("Server confirmed it recieved a valid UserProfile.", Logger.Category.NETWORK)
		SIG_server_handshake.emit(true)

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

## Only used when detecting other peers over LAN/NAT
func _process(_delta: float) -> void:
	# TODO: Implement 'server_accessibility'
	
	# Client is listening for peers over LAN
	if (_listening_for_lan_host_peers && !_host && _udp_socket.get_available_packet_count() > 0):
		var packet := _udp_socket.get_packet()  # Get the incoming packet
		var packet_message := packet.get_string_from_utf8()  # Convert packet to a string
		
		# Get the IP address of the sender
		var sender_ip := _udp_socket.get_packet_ip()
		
		# The sender is a host, add to known_peers list
		if (packet_message == _HOST_PEER_BROADCAST_MESSAGE && !_host):
			Logger.logMsg("Discovered host at IP: " + sender_ip, Logger.Category.NETWORK)
			if (!_known_host_peers.has(sender_ip)):
				_known_host_peers.append(sender_ip)
	# Client is listening for peers over NAT
	elif (_listening_for_lan_host_peers && !_host):
		pass
	# Servers is broadcasting a discovery signal to peers
	elif (_broadcasting_server_to_peers && _host):
		pass

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Get known hosts actively looking for clients
func getKnownHosts() -> Array[String]:
	return _known_host_peers

## Set the current client's host status
## @param host_state: Boolean of if the client is the host or not
func setHostState(host_state: bool) -> void:
	_host = host_state
	# TODO: Do host transfer stuff here if i implement it

## Connect to a host peer
## @param host_peer_ip_addr: IP Address of the host to connect to
func connectToHost(host_ip_addr: String) -> void:
	Logger.logMsg("Attempting to connect to host (%s)." % host_ip_addr, Logger.Category.NETWORK)
	
	# Ensure client is no longer listening for peers
	stopListeningForHosts()
	
	# If enet is not setup, setup enet
	if (_multiplayer_enet == null): _multiplayer_enet = ENetMultiplayerPeer.new()
	
	# Create server
	_multiplayer_enet.create_client(host_ip_addr, _MULTIPLAYER_ENET_PORT_NUMBER)
	multiplayer.multiplayer_peer = _multiplayer_enet
	Logger.logMsg("Connected to host (%s)!" % host_ip_addr, Logger.Category.NETWORK)

## Disconnect from the host (or simply close the server if you are the host)
func disconnectFromHost() -> void:
	Logger.logMsg("Disconnected from host.", Logger.Category.NETWORK)
	
	if (_host):
		# TODO: Do stuff for connected clients here so they don't
		# send data to a missing server and stuff
		pass
	
	multiplayer.multiplayer_peer = null
	_multiplayer_enet = null
	
	# TODO: Should probably go to the lobby scene too

## Set the current client to the host peer
func becomeHost() -> void:
	Logger.logMsg("Setting up server session.", Logger.Category.NETWORK)
	
	# Ensure client is no longer listening for peers
	stopListeningForHosts()
	
	# # Create server | If enet is not setup, setup enet
	if (_multiplayer_enet == null): _multiplayer_enet = ENetMultiplayerPeer.new()
	_multiplayer_enet.create_server(_MULTIPLAYER_ENET_PORT_NUMBER, _MULTIPLAYER_ENET_MAX_CLIENTS)
	multiplayer.multiplayer_peer = _multiplayer_enet
	setHostState(true)

## Open your host server to other peers
func openServerToPeers() -> void:
	Logger.logMsg("Opening server session to peers.", Logger.Category.NETWORK)
	
	# Setup UDP connection on local network
	if (_udp_socket == null): _udp_socket = PacketPeerUDP.new()
	_udp_socket.set_broadcast_enabled(true)
	
	# Set peers to lit
	_broadcasting_server_to_peers = true
	_broadcastServerConnection()

## Listen for p2p connections on LAN
func listenForLANHosts() -> void:
	if (_host): return # Hosts do not need to find any peers
	Logger.logMsg("Listening for hosts over LAN", Logger.Category.NETWORK)
	
	# Setup UDP connection on local network
	if (_udp_socket == null): _udp_socket = PacketPeerUDP.new()
	var err = _udp_socket.bind(_LAN_PEER_DISCOVERY_PORT_NUMBER, _LAN_IPV4_ADDRESSES)
	
	# Check for udp error
	if (err != OK):
		Logger.logMsg("Failed to bind UDP port " + str(_LAN_PEER_DISCOVERY_PORT_NUMBER), Logger.Category.NETWORK)
		return
	
	# Set client to listening state
	_listening_for_lan_host_peers = true
	_known_host_peers = []

## Listen for p2p connections over the internet
func listenForNATHosts() -> void:
	if (_host): return # Hosts do not need to find any peers
	Logger.logMsg("Listening for hosts over NAT", Logger.Category.NETWORK)
	
	# TODO: Need a middle-man server to facilitate connections or something
	
	# IDEA: The game can get the computer's ip address and map it to an integer
	# then your friend can tell you that integer and the client will reverse engineer the mapping
	# and get the ip address, making it so there is no need for an external server to facilitate
	# connections between peers.
	
	# Set client to listening state
	_listening_for_nat_host_peers = true
	_known_host_peers = []

## Stop the current client from listening for any more peers
func stopListeningForHosts() -> void:
	Logger.logMsg("Stopped listening for hosts.", Logger.Category.NETWORK)
	
	if (_listening_for_lan_host_peers):
		_listening_for_lan_host_peers = false
		_udp_socket = null
	if (_listening_for_nat_host_peers):
		_listening_for_nat_host_peers = false

## Is the current client listening for peers
## @returns: Boolean state of listening for peers
func isListeningForHosts() -> bool:
	return _listening_for_lan_host_peers || _listening_for_nat_host_peers

## Stop the current host client from broadcasting its server to peers
func stopBroadcastingToPeers() -> void:
	Logger.logMsg("Stopped broadcasting server to peers.", Logger.Category.NETWORK)
	
	if (_broadcasting_server_to_peers):
		_broadcasting_server_to_peers = false

## Is the current host client broadcasting its server to peers
## @returns: Boolean state of broadcasting to peers
func isBroadcastingToPeers() -> bool:
	return _broadcasting_server_to_peers

## Used to validate the connection between the host ansd peer
func validateConnection() -> bool:
	Logger.logMsg("Attempting to validate connection with host...", Logger.Category.NETWORK)
	Callable(_clientToServerHandshake).rpc(UserProfile)
	
	# Wait for result of handshake
	var result = await self.SIG_server_handshake
	return result

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
