extends Node3D
class_name WorldData

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## World
## 
## Base class of all world, defines essential methods for them to function
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

@onready var world_environment := $WorldEnvironment ## Simply a Godot world environment node
@onready var lighting := $Lighting ## All lighting on the map
@onready var terrain := $Terrain ## ALL terrain on the map (anything that CANNOT move)
@onready var dynamic := $Dynamic ## Holds everything that isn't preset and doesn't need a real group (particles, flying bullets, etc.)
@onready var projectiles := $Dynamic/Projectiles ## Holds projectile type dynamic objects
@onready var entities := $Entities/Other ## Holds any entity that isn't grouped
@onready var players := $Entities/Players ## Holds only player entities
@onready var enemies := $Entities/Enemies ## Holds only enemy entities
@onready var loot := $Entities/Loot ## Holds loot entities (chests, weapons, abilities)
@onready var other_entities := $Entities/Other ## Misc. entities

@export var _world_gravity: float = 9.8 ## Gravity of the world (9.8 units/s^2 by default)

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Wait until the node is ready to continue
## NOTE: Must use keyword 'await'
func _waitUntilReady() -> void:
	if (!self.is_node_ready()):
		await self.ready 

## Reparent an existing node to the world_data scene tree
## @param node: Node to reparent
## @param category: Category to add the node to (Entitiies, Dynamic, Lighting, etc.)
func _addNode(node: Node, category: Node3D) -> void:
	category.call_deferred("add_child", node)

## Add a packed scene to the scene tree
## @param packed_scene: Packed scene to instantiate and add
## @param category: Category to add the node to (Entities, Dynamic, Lighting, etc.)
func _addPackedScene(packed_scene: PackedScene, category: Node3D) -> void:
	var instance := packed_scene.instantiate()
	category.call_deferred("add_child", instance)

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #



# TODO: Stuff like 'find_all_player_positions' or 'add_player'



## WORLD_SETTINGS

## Get the gravity constant of the world
## @returns: float: Gravitational constant
func getGravity() -> float:
	return _world_gravity

## WORLD_DATA

## Set the world environment of the world
func setWorldEnvironment(new_world_environment: WorldEnvironment) -> void:
	# Don't add child until scene is ready
	await _waitUntilReady()
	
	world_environment = new_world_environment

## Add a Node3D as lighting
## @param new_lighting: New lighting PackedScene to add
func addLighting(new_lighting: Node3D) -> void:
	# Don't add child until scene is ready
	await _waitUntilReady()
	
	_addNode(new_lighting, lighting)

## Add a PackedScene as a lighting node
## @param new_lighting: New lighting PackedScene to add
func addLightingFromPackedScene(new_lighting: PackedScene) -> void:
	# Don't add child until scene is ready
	await _waitUntilReady()
	
	_addPackedScene(new_lighting, lighting)

## Add a Node3D as terrain
## @param new_terrain: Terrain PackedScene to add
func addTerrain(new_terrain: Node3D) -> void:
	# Don't add child until scene is ready
	await _waitUntilReady()
	
	_addNode(new_terrain, terrain)

## Add a PackedScene as terrain node
## @param new_terrain: Terrain PackedScene to add
func addTerrainFromPackedScene(new_terrain: PackedScene) -> void:
	# Don't add child until scene is ready
	await _waitUntilReady()
	
	_addPackedScene(new_terrain, terrain)

## Add a Node3D as a dynamic object
## @param new_dynamic_object: Dynamic object to add
func addDynamicObject(new_dynamic_object: Node3D) -> void:
	# Don't add child until scene is ready
	await _waitUntilReady()
	
	_addNode(new_dynamic_object, dynamic)

## Add a PackedScene as a dynamic object
## @param new_dynamic_object: Dynamic object to add
func addDynamicObjectFromPackedScene(new_dynamic_object: PackedScene) -> void:
	# Don't add child until scene is ready
	await _waitUntilReady()
	
	_addPackedScene(new_dynamic_object, dynamic)

## Add a Node3D as a dynamic object
## @param new_dynamic_object: Dynamic object to add
func addDynamicProjectileObject(new_dynamic_projectile_object: Node3D) -> void:
	# Don't add child until scene is ready
	await _waitUntilReady()
	
	_addNode(new_dynamic_projectile_object, projectiles)

## Add a PackedScene as a dynamic object
## @param new_dynamic_object: Dynamic object to add
func addDynamicProjectileObjectFromPackedScene(new_dynamic_projectile_object: PackedScene) -> void:
	# Don't add child until scene is ready
	await _waitUntilReady()
	
	_addPackedScene(new_dynamic_projectile_object, projectiles)

## Add a Node3D as an entity
## @param new_entity: Entity to add
func addEntity(new_entity: Node3D) -> void:
	# Don't add child until scene is ready
	await _waitUntilReady()
	
	_addNode(new_entity, entities)

## Add a PackedScene as an entity
## @param new_entity: Entity to add
func addEntityFromPackedScene(new_entity: PackedScene) -> void:
	# Don't add child until scene is ready
	await _waitUntilReady()
	
	_addPackedScene(new_entity, entities)

## Add a Node3D as a player entity
## @param new_player: Player to add
func addPlayerEntity(new_player: Node3D) -> void:
	# Don't add child until scene is ready
	await _waitUntilReady()
	
	_addNode(new_player, players)

## Add a PackedScene as a player entity
## @param new_player: Player to add
func addPlayerEntityFromPackedScene(new_player: PackedScene) -> void:
	# Don't add child until scene is ready
	await _waitUntilReady()
	
	_addPackedScene(new_player, players)

## Add a Node3D as an enemy entity
## @param new_enemy: Enemy to add
func addEnemyEntity(new_enemy: Node3D) -> void:
	# Don't add child until scene is ready
	await _waitUntilReady()
	
	_addNode(new_enemy, enemies)

## Add a PackedScene as an enemy entity
## @param new_enemy: Enemy to add
func addEnemyEntityFromPackedScene(new_enemy: PackedScene) -> void:
	# Don't add child until scene is ready
	await _waitUntilReady()
	
	_addPackedScene(new_enemy, enemies)

## Add a Node3D as a loot entity
## @param new_loot: Loot to add
func addLootEntity(new_loot: Node3D) -> void:
	# Don't add child until scene is ready
	await _waitUntilReady()
	
	_addNode(new_loot, loot)

## Add a PackedScene as a loot entity
## @param new_loot: Loot to add
func addLootEntityFromPackedScene(new_loot: PackedScene) -> void:
	# Don't add child until scene is ready
	await _waitUntilReady()
	
	_addPackedScene(new_loot, loot)

## Add a Node3D as an other entity
## @param new_loot: Misc. entity to add
func addOtherEntity(new_other: Node3D) -> void:
	# Don't add child until scene is ready
	await _waitUntilReady()
	
	_addNode(new_other, other_entities)

## Add a PackedScene as an other entity
## @param new_loot: Misc. entity to add
func addOtherEntityFromPackedScene(new_other: PackedScene) -> void:
	# Don't add child until scene is ready
	await _waitUntilReady()
	
	_addPackedScene(new_other, other_entities)

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
