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

@onready var world_environment := $WorldEnvironment
@onready var terrain := $Terrain ## ALL terrain on the map (anything that CANNOT move)
@onready var entities := $Entities/Other ## Holds any entity that isn't grouped
@onready var players := $Entities/Players ## Holds only player entities
@onready var enemies := $Entities/Enemies ## Holds only enemy entities
@onready var loot := $Entities/Loot ## Holds loot entities (chests, weapons, abilities)
@onready var dynamic := $Dynamic ## Holds everything that isn't preset and doesn't need a real group (particles, flying bullets, etc.)

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

## Add a Node3D as terrain
## @param new_terrain: Terrain resource to add
func addTerrain(new_terrain: PackedScene) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready
	
	var instance := new_terrain.instantiate()
	terrain.call_deferred("add_child", instance)

## Set the world environment of the world
func setWorldEnvironment(new_world_environment: WorldEnvironment) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready 
	
	world_environment = new_world_environment

# TODO: Look into changing these node types in the paramters of these upcoming functions

## Add a new entity to the world
## @param new_entity: Entity to add
func addEntity(new_entity: Node3D) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready 
	
	entities.call_deferred("add_child", new_entity)

## Add a new player to the world
## @param new_player: Player to add
func addPlayerEntity(new_player: Node3D) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready
	
	players.call_deferred("add_child", new_player)

## Add a new enemy to the world
## @param new_enemy: Enemy to add
func addEnemyEntity(new_enemy: Node3D) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready 
	
	enemies.call_deferred("add_child", new_enemy)

## Add new loot to the world
## @param new_loot: Loot to add
func addLootEntity(new_loot: Node3D) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready 
	
	loot.call_deferred("add_child", new_loot)

## Add a new dynamic object to the world
## @param new_dynamic_object: Dynamic object to add
func addDynamicObject(new_dynamic_object: Node3D) -> void:
	# Don't add child until scene is ready
	if (!self.is_node_ready()):
		await self.ready 
	
	dynamic.call_deferred("add_child", new_dynamic_object)

# TODO: Stuff like 'find_all_player_positions' or 'add_player'

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
