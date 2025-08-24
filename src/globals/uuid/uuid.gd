extends Node

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## UUID Singleton
## 
## Defines a UUID system for giving unique identifiers to nodes and stores the path to the
## node to access easily over the network
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

signal SIG_uuid_counter_synced()
signal SIG_freed_uuids_synced()

## Index of the UUID paramter of arrays passed to an "initialize" function
const INITIALIZER_ARRAY_UUID_INDEX: int = 0 

var _uuid_counter := 0 ## Current counter for unique ids | NOTE: These are only unique until a node is freed, IDS WILL be reused when available
var _freed_uuids: Array[int] = [] ## Holds ids that have been queue_free'd

# local vars
var _uuids: Dictionary = { ## Unique ids for every node, and the path to that node
	# { UUID : Local NodePath }
}

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Called from clients to request the up-to-date info on the 'uuid counter'
## NOTE: This shouldn't be necessary outside of 'generateNewUuid()'
@rpc("any_peer", "call_remote", "reliable")
func _requestSyncUuidCounter() -> void:
	# Call on all clients("Except itself since it is already set)
	_syncUuidCounterOnClients.rpc(_uuid_counter)

## Called from the authority and sent to all peers. This updates the value for
## the 'uuid counter' to match the authority
## @param value: _uuid_counter's value on the authority client
## NOTE: Helper function to '_requestSyncUuidCounter()'
@rpc("authority", "call_remote", "reliable")
func _syncUuidCounterOnClients(value: int) -> void:
	# Set value recieved from the server
	_uuid_counter = value
	SIG_uuid_counter_synced.emit()

## Called from clients to request the up-to-date info on the 'freed uuids' array
## NOTE: This shouldn't be necessary outside of 'generateNewUuid()'
@rpc("any_peer", "call_remote", "reliable")
func _requestSyncFreeUuidsArray() -> void:
	# Call on all clients("Except itself since it is already set)
	_syncFreeUuidsArrayOnClients.rpc(_freed_uuids)

## Called from the authority and sent to all peers. This updates the value for
## the 'freed uuids' array to match the authority
## @param value: _freed_uuids's value on the authority client
## NOTE: Helper function to '_requestSyncFreeUuidsArray()'
@rpc("authority", "call_remote", "reliable")
func _syncFreeUuidsArrayOnClients(value: Array[int]) -> void:
	# Set value recieved from the server
	_freed_uuids = value
	SIG_freed_uuids_synced.emit()

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Set the UUID metadata on a node
## @param node: Node to set the UUID on
## @param uuid: UUID to give the node
func setMetadata(node: Node, uuid: int) -> void:
	node.set_meta(Metadata.UUID, uuid)

## Actually assigns the node to the
## @param node_path: Path to the node to reference on the UUID
## @param uuid: UUID to give the node
func assignNodeToDictionary(node_path: NodePath, uuid: int) -> void:
	# Add to the dictionary
	_uuids[uuid] = node_path

## Generates a new unique UUID that, with the responsibility of the programmer,
## is assigned to a node with "initialize".
## NOTE: UUID is ALWAYS index '0' of the paramater array | Can use Utils.INITIALIZER_ARRAY_UUID_INDEX as a substitute
## @returns int: New Universally-Unique ID
func generateNewUuid() -> int:
	# If the current client is NOT the server, then we need to request the
	# up-to-date data for the freed uuids array
	if (!P2PNetworking.isServer()):
		_requestSyncFreeUuidsArray.rpc_id(P2PNetworking.HOST_PEER_ID)
		await SIG_freed_uuids_synced
	
	# Get the lowest number from the free_uuids array
	if (!_freed_uuids.is_empty()):
		# Since this array is always sorted, we can just choose the front
		return _freed_uuids.pop_front()
	
	# If the current client is NOT the server, then we need to request the
	# up-to-date data for the uuid counter
	if (!P2PNetworking.isServer()):
		_requestSyncUuidCounter.rpc_id(P2PNetworking.HOST_PEER_ID)
		await SIG_uuid_counter_synced
	
	# If the array is empty, just increment the counter and return the pre-incremented value
	var temp := _uuid_counter
	_uuid_counter += 1
	return temp

## Reassign the NodePath part of a UUID in the dictionary
## NOTE: You should use this by calling a reparent method, then extracting the uuid
##       of the node that was reparented, then, get the node
## @param uuid: UUID to reassign
## @param node: New path to the node
func setUuidToNewNodePath(uuid: int, node_path: NodePath) -> void:
	# Return if the UUID doesnt exist
	if (!_uuids.has(uuid)):
		return
	
	_uuids[uuid] = node_path

## Free a uuid from the dictionary
## @param uuid: UUID to free
@rpc("any_peer", "call_local", "reliable")
func freeUuid(uuid: int) -> void:
	# Return if the UUID doesnt exist
	if (!_uuids.has(uuid)):
		return
	
	# Erase UUID from dictionary
	_uuids.erase(uuid)
	
	# Add the newly freed UUID to the set of freed UUIDS and sort to keep predictable
	_freed_uuids.append(uuid)
	_freed_uuids.sort()

## Given a uuid, get the local node object it corresponds to
## @param uuid: Unique id of a node
## @returns Node: The node the NodePath part of the UUID dictionary points to
func getNodeFromUuid(uuid: int) -> Node:
	# If the uuid doesn't exist, just return null
	if (!_uuids.has(uuid)):
		return null
	
	var node_path: NodePath = _uuids[uuid]
	var node: Node = get_node_or_null(node_path)
	
	return node

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
