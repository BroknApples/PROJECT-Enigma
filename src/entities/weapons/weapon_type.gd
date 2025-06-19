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

@onready var _projectile_spawn_point := $ProjectileSpawnPoint ## Point in the world where the projectiles should spawn

## Holds all the different projectiles that this weapon can use
var _projectiles: Array[PackedScene] = []

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## The default input event responses
## @param event: InputEvent to check
func _defaultInputs(event: InputEvent) -> void:
	# PRIMARY ATTACK
	if (Input.is_action_just_pressed(Keybinds.ActionNames.PRIMARY_ATTACK)):
		doPrimaryAttack()
	# SECONDARY ATTACK
	elif (Input.is_action_just_pressed(Keybinds.ActionNames.SECONDARY_ATTACK)):
		doSecondaryAttack()

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _input(event: InputEvent) -> void:
	_defaultInputs(event)

func _ready() -> void:
	pass
	# TODO: Implement necesary things

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Do a primary attack
func doPrimaryAttack() -> void:
	# NOTE: Implement in each child weapon type
	pass

## Do a secondary attack
func doSecondaryAttack() -> void:
	# NOTE: Implement in each child weapon type
	pass

## Get the position for the projectiles to spawn
## @return Transform3D: Place in the world to spawn the 
func getProjectileSpawnPointTransform3D() -> Transform3D:
	return _projectile_spawn_point.global_transform

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
