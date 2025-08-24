extends Node3D
class_name ChunkData

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## ChunkData
## 
## Base class of all world, defines essential methods for them to function
## 

# TODO: Change this to a ChunkData type, each chunk will have all of these data nodes,
# When a player changes their region, in the world scene, just simply reparent the player node;
# same with any other object

#TODO: On the case of syncing spawned nodes:
#Player enters the chunk’s area (e.g., an Area3D node).
#Client sends an RPC to the server:
#“Hey server, I’m entering this chunk area, can I control spawning here?”
#Server checks if the chunk is free:
#If yes, assigns the player’s PEER_ID as the controlled_by owner of that chunk and lets them spawn enemies.
#If no (someone else owns it), denies or ignores the request.
#While the player owns the chunk
#They can trigger spawn events or the chunk can operate autonomously, tied to that owner.
#When the player leaves the area:
#The client sends another RPC: “I’m leaving the chunk area.”
#Server clears the controlled_by so others can take control.
#
# NOTE: The client that owns the chunk should do all the processing for figuring out WHAT to spawn, but
# the host/server is still responsile for actually spawning the node through the multiplayerSpawner
#
# NOTE: A REALLY GOOD IDEA IS PREDICTING THE SPAWNS FOR THE ENITE BATCH OF ENEMIES and sending
# the entire predicted data across the server. Reduces the amount of rpc calls and the size of
# the rpc calls.

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner ## Multiplayer spawner node for syncing nodes across the network
@onready var world_environment: WorldEnvironment = $WorldEnvironment ## Simply a Godot world environment node
@onready var particles := $Particles ## All particles on the map
@onready var particles_node_path := particles.get_path() ## Path to the particles node
@onready var lighting := $Lighting ## All lighting on the map
@onready var lighting_node_path := lighting.get_path() ## Path to the lighting node
@onready var terrain: NavigationRegion3D = $Terrain ## ALL terrain on the map (anything that CANNOT move)
@onready var terrain_node_path := terrain.get_path() ## Path to the terrain node
@onready var dynamic := $Dynamic ## Holds everything that isn't preset and doesn't need a real group (particles, flying bullets, etc.)
@onready var dynamic_node_path := dynamic.get_path() ## Path to the dynamic node
@onready var projectiles := $Dynamic/Projectiles ## Holds projectile type dynamic objects
@onready var projectiles_node_path := projectiles.get_path() ## Path to the projectiles node
@onready var entities := $Entities/Other ## Holds any entity that isn't grouped
@onready var entities_node_path := entities.get_path() ## Path to the entities node
@onready var players := $Entities/Players ## Holds only player entities
@onready var players_node_path := players.get_path() ## Path to the players node
@onready var enemies := $Entities/Enemies ## Holds only enemy entities
@onready var enemies_node_path := enemies.get_path() ## Path to the enemies node
@onready var loot := $Entities/Loot ## Holds loot entities (chests, weapons, abilities)
@onready var loot_node_path := loot.get_path() ## Path to the loot node
@onready var other_entities := $Entities/Other ## Misc. entities
@onready var other_entities_node_path := other_entities.get_path() ## Path to the other_entities node

@export var _world_gravity: float = 9.8 ## Gravity of the world (9.8 units/s^2 by default)

## These items are things that MUST be in the spawn list as they will be on EVERY SINGLE WORLD
## NOTE - These will include:
## PlayerCharacters,
## Every Weapon,
## Every Ability,
## Every Projectile,
var _default_spawn_list := [
	# PlayerCharacter
	AssetManager.getAssetPath(AssetManager.Assets.PLAYER_CHARACTER_TYPE_SCENE),
	
	# Weapons
	
	# Abilities
	
	# Projectiles
	AssetManager.getAssetPath(AssetManager.Assets.BLASTER_PROJECTILE_SCENE),
]

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# TODO: Change from any_peer to authority, though this requires another helper function that sends
# the request to the authority along with data needed for the request to work.

## Reparent an existing node to the world_data scene tree
## NOTE: Utilizes an rpc call to replicate over the network
## NOTE: Assumes that the node has already called "initialize"
## @param node_uuid: UUID of the to the node to reparent
## @param category_path: Path to the category to add the node to (Entities, Dynamic, Lighting, etc.)
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
@rpc("any_peer", "call_local", "unreliable")
func _reparentNode(node_uuid: int, category_path: NodePath) -> void:
	var node = UUID.getNodeFromUuid(node_uuid)
	
	# If node is null, just return, an invalid path was passed
	if (node == null):
		Logger.logMsg("Attempted to use an invalid node path to reparent a node", Logger.Category.ERROR)
		return
	
	# Doesn't have to reparent if there isn't a parent
	if (node.get_parent() == null):
		get_node(category_path).call_deferred(&"add_child", node)
	# Reparent if there is a parent
	else:
		node.call_deferred(&"reparent", get_node(category_path))

## Add a packed scene to the scene tree
## NOTE: Utilizes an rpc call to replicate over the network
## @param packed_scene: Packed scene to instantiate and add
## @param category_path: Path to the category to add the node to (Entities, Dynamic, Lighting, etc.)
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
@rpc("any_peer", "call_local", "unreliable")
func _addPackedScene(packed_scene: PackedScene, category_path: NodePath, initialize_arr: Array) -> void:
	# Use RPC to spawn PackedScenes
	var instance := packed_scene.instantiate()
	get_node(category_path).call_deferred(&"add_child", instance)
	
	# If an initialize function exist, call it with the correct data
	if (instance.has_method("initialize")):
		instance.initialize.rpc(initialize_arr)

## Add a packed scene to the scene tree
## NOTE: Utilizes a MultiplayerSpawner to replicate over the network	
## @param scene_path: Path to the scene to add (This must already be in the spawn list of the multiplayer spawner)
## @param category_path: Path to the category to add the node to (Entities, Dynamic, Lighting, etc.)
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func _addSceneFromFilePath(scene_path: StringName, category_path: NodePath, initialize_arr: Array) -> void:
	# Run THIS code when playing in multiplayer sessions
	if (P2PNetworking.isNetworking()):
		# Use MultiplayerSpawner to spawn using the file path
		# (It must be registered already or it won't work as expected).
		_syncSpawnPath.rpc(category_path)
		
		var scene: PackedScene = load(String(scene_path))
		var instance: Node = scene.instantiate()
		
		# Add node to tree -> This initiates the replication on peers
		var category := get_node_or_null(category_path)
		category.add_child(instance, true)
		
		# If an initialize function exist, call it
		# with the correct data on all peers
		if (instance.has_method("initialize")):
			instance.initialize.rpc(initialize_arr)
		
		# TODO: Check if the current client is the authority before doing
		# anything in the '...FromFilePath' functions
	
	# Run THIS code when in singleplayer settings
	else:
		var category := get_node_or_null(category_path)
		
		var instance = load(String(scene_path)).instantiate()
		
		# If an initialize function exist, call it with the correct data
		if (instance.has_method("initialize")):
			instance.initialize.rpc(initialize_arr)
		
		# Add node to the tree
		category.add_child(instance)

## Sync the spawn path for a multiplayer spawner over rpc
## @param category_path: New spawn path
@rpc("any_peer", "call_local", "reliable")
func _syncSpawnPath(path: NodePath) -> void:
	multiplayer_spawner.spawn_path = path

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# Add default spawn list items
	for item in _default_spawn_list:
		multiplayer_spawner.add_spawnable_scene(item)

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Regiseter a list of spawnable scenes to the multiplayer spawner on each client
## @param spawn_list: List of scene paths to register
@rpc("authority", "call_local", "reliable")
func registerSpawnableScenes(spawn_list: Array[StringName]) -> void:
	for item in spawn_list:
		multiplayer_spawner.add_spawnable_scene(item)



# TODO: Stuff like 'findAllPlayerPositions' or 'findAllEnemyPositions' or 'findAllLootPositions', etc.



## WORLD_SETTINGS

## Get the gravity constant of the world
## @returns: float: Gravitational constant
func getGravity() -> float:
	return _world_gravity

## WORLD_DATA

## Set the world environment of the world
func setWorldEnvironment(new_world_environment: WorldEnvironment) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	world_environment = new_world_environment

## Add a Node3D as a particle effect
## @param particle: Particle to add to the world
func addParticleEffect(particle: Node3D) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Add particle under the 'particles' section
	particles.add_child(particle)

## Add a Node3D as lighting
## @param node: New lighting PackedScene to add
func reparentLighting(node: Node3D, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_reparentNode.rpc(node.get_meta(Metadata.UUID), lighting_node_path)

## Add a PackedScene as a lighting node
## @param scene: New lighting PackedScene to add
func addLightingFromPackedScene(scene: PackedScene, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_addPackedScene.rpc(scene, lighting_node_path, initialize_arr)

## Add a scene file path's instance as lighting
## @param path: Lighting to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func addLightingFromFilePath(path: StringName, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_addSceneFromFilePath(path, lighting_node_path, initialize_arr)

## Add a Node3D as terrain
## @param node: Terrain PackedScene to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func reparentTerrain(node: Node3D, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_reparentNode.rpc(node.get_meta(Metadata.UUID), terrain_node_path)

## Add a PackedScene as terrain node
## @param scene: Terrain PackedScene to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func addTerrainFromPackedScene(scene: PackedScene, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)

	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_addPackedScene.rpc(scene, terrain_node_path, initialize_arr)

## Add a scene file path's instance as terrain
## @param path: Terrain to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func addTerrainFromFilePath(path: StringName, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_addSceneFromFilePath(path, terrain_node_path, initialize_arr)

## Add a Node3D as a dynamic object
## @param node: Dynamic object to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func reparentDynamicObject(node: Node3D, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_reparentNode.rpc(node.get_meta(Metadata.UUID), dynamic_node_path)

## Add a PackedScene as a dynamic object
## @param scene: Dynamic object to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func addDynamicObjectFromPackedScene(scene: PackedScene, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_addPackedScene.rpc(scene, dynamic_node_path, initialize_arr)

## Add a scene file path's instance as a dynamic object
## @param path: Dynamic object to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func addDynamicObjectFromFilePath(path: StringName, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_addSceneFromFilePath(path, dynamic_node_path, initialize_arr)

## Add a PackedScene as a dynamic projectile object
## @param node: Dynamic object to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func reparentDynamicProjectileObject(node: Node3D, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_reparentNode.rpc(node.get_meta(Metadata.UUID), projectiles_node_path)

## Add a PackedScene as a dynamic projectile object
## @param scene: Entity to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func addDynamicProjectileObjectFromPackedScene(scene: PackedScene, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_addPackedScene.rpc(scene, projectiles_node_path, initialize_arr)

## Add a scene file path's instance as a dynamic projectile object
## @param path: Dynamic object to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func addDynamicProjectileObjectFromFilePath(path: StringName, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_addSceneFromFilePath(path, projectiles_node_path, initialize_arr)

## Add a Node3D as an entity
## @param node: Entity to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func reparentEntity(node: Node3D, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_reparentNode.rpc(node.get_meta(Metadata.UUID), entities_node_path)

## Add a PackedScene as an entity
## @param scene: Entity to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func addEntityFromPackedScene(scene: PackedScene, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_addPackedScene.rpc(scene, entities_node_path, initialize_arr)

## Add a PackedScene as an entity
## @param path: Entity to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func addEntityFromFilePath(path: StringName, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_addSceneFromFilePath(path, entities_node_path, initialize_arr)

## Add a Node3D as a player entity
## @param node: Player to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func reparentPlayerEntity(node: PlayerCharacterType, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_reparentNode.rpc(node.get_meta(Metadata.UUID), players_node_path)

## Add a PackedScene as a player entity
## @param scene: Player to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func addPlayerEntityFromPackedScene(scene: PackedScene, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_addPackedScene.rpc(scene, players_node_path, initialize_arr)

## Add a PackedScene as a player entity
## @param path: Player to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func addPlayerEntityFromFilePath(path: StringName, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_addSceneFromFilePath(path, players_node_path, initialize_arr)

## Add a Node3D as an enemy entity
## @param node: Enemy to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func reparentEnemyEntity(node: Node3D, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_reparentNode.rpc(node.get_meta(Metadata.UUID), enemies_node_path)

## Add a PackedScene as an enemy entity
## @param scene: Enemy to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func addEnemyEntityFromPackedScene(scene: PackedScene, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_addPackedScene.rpc(scene, enemies_node_path, initialize_arr)

## Add a PackedScene as a enemy entity
## @param path: Enemy to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func addEnemyEntityFromFilePath(path: StringName, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_addSceneFromFilePath(path, enemies_node_path, initialize_arr)

## Add a Node3D as a loot entity
## @param node: Loot to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func reparentLootEntity(node: Node3D, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_reparentNode.rpc(node.get_meta(Metadata.UUID), loot_node_path)

## Add a PackedScene as a loot entity
## @param scene: Loot to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func addLootEntityFromPackedScene(scene: PackedScene, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_addPackedScene.rpc(scene, loot_node_path, initialize_arr)

## Add a PackedScene as a loot entity
## @param path: Player to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func addLootEntityFromFilePath(path: StringName, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_addSceneFromFilePath(path, loot_node_path, initialize_arr)

## Add a Node3D as an 'other' entity
## @param node: Misc. entity to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func reparentMiscEntity(node: Node3D, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_reparentNode.rpc(node.get_meta(Metadata.UUID), other_entities_node_path)

## Add a PackedScene as an 'other' entity
## @param scene: Misc. entity to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func addMiscEntityFromPackedScene(scene: PackedScene, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_addPackedScene.rpc(scene, other_entities_node_path, initialize_arr)

## Add a PackedScene as an 'other' entity
## @param path: Misc. entity to add
## @param initialize_arr: Array full of data used to initialize the object. NOTE: THIS CANNOT CONTAIN NODES; MUST BE PURELY DATA
func addMiscEntityFromFilePath(path: StringName, initialize_arr: Array = []) -> void:
	# Don't add child until scene is ready
	await Utils.waitUntilNodeReady(self)
	
	# Array[0] should always be the UUID
	initialize_arr.push_front(await UUID.generateNewUuid())
	
	# NOTE: Save some bandwidth with default params when possible
	_addSceneFromFilePath(path, other_entities_node_path, initialize_arr)

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
