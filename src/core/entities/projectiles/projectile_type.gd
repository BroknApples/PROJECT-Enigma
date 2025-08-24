@tool
extends Node3D
class_name ProjectileType

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## ProjectileType
## 
## Base class of all projectiles
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

signal SIG_initialized()

var _damage_component: DamageComponent = null
var _initial_transform_data: Transform3D
var _initial_scale: Vector3
var _team: int ## Which collision layer should this projectile NOT detect (in terms of entities)

@export var _color: Color:
	set(value):
		_color = value
		
		# Override this function in child classes
		# to visibly set the color in the editor
		_applyColorToMesh()

## Has this projectile been initialized using a initialize() function?
var _initialized := false

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Apply the current value of '_color' to the mesh object of the projectile
func _applyColorToMesh() -> void:
	pass

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Initialize projectile
## @param initialize_arr: Initializer array with data as such:
## damage_component_path: DamageComponent, transform_data: Transform3D, projectile_scale: Vector3
@rpc("any_peer", "call_local", "reliable")
func initialize(initialize_arr: Array) -> void:
	# Set UUID
	UUID.setMetadata(self, initialize_arr[UUID.INITIALIZER_ARRAY_UUID_INDEX])
	
	# Set damage component
	_damage_component = Utils.GAME_ROOT.get_node_or_null(initialize_arr[1])
	
	# Set transform data
	_initial_transform_data = initialize_arr[2]
	
	# Set scale data
	_initial_scale = initialize_arr[3]
	
	# Set team value
	_team = initialize_arr[4]
	
	# Set this projectile as initialized
	_initialized = true
	SIG_initialized.emit()

## Assign a new team to the projectile.
## @param team: Team number
## @param object: Which object has the collision mask, typically is 'self'
func assignTeam(new_team: int, object: Variant = self) -> void:
	var other_teams: Array[int] = Utils.getOtherTeams(new_team)
	for team in other_teams:
		object.collision_mask |= (1 << team)

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
