extends Node3D
class_name WeaponType

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## WeaponType
## 
## Base class of all weapons; implements basic ideas such as
## element, damage stats, model, etc.
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

signal SIG_initialized()

@onready var _projectile_spawn_point: TransformMarker3D = $ProjectileSpawnPoint ## Point in the world where the projectiles should spawn

## Holds all the different projectiles that this weapon can use
var _projectiles: Array[StringName] = []

var _initialized: bool = false ## Is this node initialized

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Internal function that does the actual work of spawning a projectile
## @param scene_path: Path the scene that will instantiated
## @param node_transform: The Transform3D of the node
## @param node_scale: The scale of the node
## @param damage_component_path: Path to the damage component the projectile will be attached to
func _spawnProjectileInternal(scene_path: StringName, node_transform: Transform3D, node_scale: Vector3, damage_component_path: NodePath, team: int) -> void:
	# Create an initializer array
	var damage_component = get_node_or_null(damage_component_path)
	var initialize_arr := [damage_component.get_path(), node_transform, node_scale, team]

	# Add to the proper location in the scene tree
	# GAME_ROOT.${WorldName}.ChunkData.Dynamic.Projectiles.${ProjectileNode}
	var chunk_data: ChunkData = Utils.getChunkDataNode()
	chunk_data.addDynamicProjectileObjectFromFilePath(scene_path, initialize_arr)

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# Set meta
	self.set_meta(Metadata.WEAPON_TYPE, true)
	
	# Wait until the node is initialized. NOTE: Disables processing until it is initialized
	await Utils.disableProcessingUntilInitialized(self)
	
	# Apply the node_path to the UUID dictionary
	UUID.assignNodeToDictionary(Utils.getNodePath(self), self.get_meta(Metadata.UUID))

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Initialize data
## @param initialize_arr: Array that holds data to initialize the node, NOTE: arr[0] is always the UUID
func initialize(initialize_arr: Array) -> void:
	# NOTE: Insert here if needed
	
	UUID.setMetadata(self, initialize_arr[UUID.INITIALIZER_ARRAY_UUID_INDEX])
	
	# Set this projectile as initialized
	_initialized = true
	SIG_initialized.emit()

## Get the character body that owns this weapon
## NOTE: will return null if it is not owned by a player
## @returns Node: Node in the scene tree
func getOwningCharacter() -> Node:
	# Structure is:
	# (1)	 "CharacterType"
	# (2)		"Head"
	# (3)			"Weapons"
	# (4)				"WeaponType" <-- Currently here
	
	# Check if the direct parent is a weapons node
	var p1: Node = self.get_parent()
	if (p1 == null || p1.name != "Weapons"):
		return null
	
	# Check if the 2nd parent is a head node
	var p2: Node = p1.get_parent()
	if (p2 == null || p2.name != "Head"):
		return null
	
	# Check if the next parent is NULL or doesn't contain the metadata for a character
	var p3: Node = p2.get_parent()
	if (p3 == null || !p3.has_meta(Metadata.CHARACTER_TYPE)):
		return null
	
	# If all checks were fine, return the 3rd parent (p3)
	return p3

## Spawn the projectile in the world
## @param scene_path: Path the scene that will instantiated
## @param node_transform: The Transform3D of the node
## @param node_scale: The scale of the node
## @param damage_component_path: Path to the damage component the projectile will be attached to
func spawnProjectile(scene_path: StringName, node_transform: Transform3D, node_scale: Vector3, damage_component_path: NodePath, team: int) -> void:
	_spawnProjectileInternal(scene_path, node_transform, node_scale, damage_component_path, team)

## Do a primary attack
func doPrimaryAttack() -> void:
	# NOTE: Implement in each child weapon type
	pass

## Do a secondary attack
func doSecondaryAttack() -> void:
	# NOTE: Implement in each child weapon type
	pass

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
