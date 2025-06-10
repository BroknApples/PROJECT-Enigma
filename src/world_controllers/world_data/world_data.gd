extends Node3D

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
@onready var entities := $Entities/Other ## Holds any entity that isn't grouped
@onready var players := $Entities/Players ## Holds only player entities
@onready var enemies := $Entities/Enemies ## Holds only enemy entities
@onready var loot := $Entities/Loot ## Holds loot entities (chests, weapons, abilities)

@export var world_gravity: float = 9.8 ## Gravity of the world (9.8 units/s^2 by default)

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## WORLD_SETTINGS

## Get the gravity constant of the world
## @returns: float: Gravitational constant
func getGravity() -> float:
	return world_gravity

## WORLD_DATA

## Set the world environment of the world
func setWorldEnvironment(new_world_environment: WorldEnvironment) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready 
	
	world_environment = new_world_environment

## Add a Node3D as lighting
## @param new_lighting: New lighting resource to add
func addLighting(new_lighting: Node3D) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready 
	
	lighting.call_deferred("add_child", new_lighting)

## Add a PackedScene as a lighting node
## @param new_lighting: New lighting resource to add
func addLightingFromResource(new_lighting: PackedScene) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready 
	
	var instance := new_lighting.instantiate()
	lighting.call_deferred("add_child", instance)

## Add a Node3D as terrain
## @param new_terrain: Terrain resource to add
func addTerrain(new_terrain: Node3D) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready
	
	terrain.call_deferred("add_child", new_terrain)

## Add a PackedScene as terrain node
## @param new_terrain: Terrain resource to add
func addTerrainFromResource(new_terrain: PackedScene) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready
	
	var instance := new_terrain.instantiate()
	terrain.call_deferred("add_child", instance)

## Add a Node3D as a dynamic object
## @param new_dynamic_object: Dynamic object to add
func addDynamicObject(new_dynamic_object: Node3D) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready 
	
	dynamic.call_deferred("add_child", new_dynamic_object)

## Add a PackedScene as a dynamic object
## @param new_dynamic_object: Dynamic object to add
func addDynamicObjectFromResource(new_dynamic_object: PackedScene) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready 
	
	var instance := new_dynamic_object.instantiate()
	dynamic.call_deferred("add_child", instance)

## Add a Node3D as an entity
## @param new_entity: Entity to add
func addEntity(new_entity: Node3D) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready 
	
	entities.call_deferred("add_child", new_entity)

## Add a PackedScene as an entity
## @param new_entity: Entity to add
func addEntityFromResource(new_entity: PackedScene) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready 
	
	var instance := new_entity.instantiate()
	entities.call_deferred("add_child", instance)

## Add a Node3D as a player entity
## @param new_player: Player to add
func addPlayerEntity(new_player: Node3D) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready
	
	players.call_deferred("add_child", new_player)

## Add a PackedScene as a player entity
## @param new_player: Player to add
func addPlayerEntityFromResource(new_player: PackedScene) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready
	
	var instance := new_player.instantiate()
	players.call_deferred("add_child", instance)

## Add a Node3D as an enemy entity
## @param new_enemy: Enemy to add
func addEnemyEntity(new_enemy: Node3D) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready 
	
	enemies.call_deferred("add_child", new_enemy)

## Add a PackedScene as an enemy entity
## @param new_enemy: Enemy to add
func addEnemyEntityFromResource(new_enemy: PackedScene) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready 
	
	var instance := new_enemy.instantiate()
	enemies.call_deferred("add_child", instance)

## Add a Node3D as a loot entity
## @param new_loot: Loot to add
func addLootEntity(new_loot: Node3D) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready 
	
	loot.call_deferred("add_child", new_loot)

## Add a PackedScene as a loot entity
## @param new_loot: Loot to add
func addLootEntityFromResource(new_loot: PackedScene) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready 
	
	var instance := new_loot.instantiate()
	loot.call_deferred("add_child", instance)




# TODO: Stuff like 'find_all_player_positions' or 'add_player'

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
