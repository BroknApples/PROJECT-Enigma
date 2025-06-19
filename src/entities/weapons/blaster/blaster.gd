extends WeaponType
class_name Blaster

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

enum ProjectileIndexes {
	BLASTER_PROJECTILE = 0,
}

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

@onready var _primary_attack_damage_component := $PrimaryAttackDamageComponent
@onready var _primary_projectile_scale := Vector3(0.5, 0.5, 0.5)

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _input(event: InputEvent) -> void:
	_defaultInputs(event)

func _ready() -> void:
	_projectiles = [
		load("res://src/entities/projectiles/laser_shot/blaster_projectile.tscn")
	]

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

# TODO: Set a private variable that holds the "team" that owns this
# weapon, then set projectile collision layers based on that

## Do a primary attack
func doPrimaryAttack() -> void:
	# Create an instance of the projectile object
	var blaster_projectile := _projectiles[ProjectileIndexes.BLASTER_PROJECTILE].instantiate()

	# Set transform data
	var blaster_projectile_transform := getProjectileSpawnPointTransform3D()
	blaster_projectile_transform.basis.y = _primary_projectile_scale
	
	# Initialize projectile data
	blaster_projectile.initialize(_primary_attack_damage_component, blaster_projectile_transform)
	
	# Add the projectile to the tree
	self.add_child(blaster_projectile)

## Do a secondary attack
func doSecondaryAttack() -> void:
	# NOTE: Implement in each child weapon type
	pass

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
