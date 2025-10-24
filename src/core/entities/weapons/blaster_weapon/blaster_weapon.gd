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
#@onready var _primary_projectile_scale := Vector3(0.5, 0.5, 0.5)
@onready var _primary_projectile_scale := Vector3(1, 1, 1)

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

var temp := 1000000
func _ready() -> void:
	# TESTING
	self.initialize([temp])
	temp += 1
	
	await super._ready()
	
	_projectiles = [
		AssetManager.getAssetPath(AssetManager.Assets.BLASTER_PROJECTILE_SCENE),
		&"res://src/core/entities/projectiles/hitscan_projectile_type.tscn"
	]

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

# TODO: Set a private variable that holds the "team" that owns this
# weapon, then set projectile collision layers based on that

## Do a primary attack
func doPrimaryAttack() -> void:
	# Get transform data
	var blaster_projectile_spawn_transform := _projectile_spawn_point.getGlobalTransform()
	
	# Spawn the projectile
	
	# TODO: Use some sort of index to get the correct node, instead of get_path() since there could
	# be an error where different clients use different paths for a node
	# NOTE: Would probably require another global script that holds every single node instanced in the game
	# and assigns a unique id to it or whatever, add this id variable to EVERY node in metadata
	
	# Spawn projectile
	spawnProjectile(_projectiles[ProjectileIndexes.BLASTER_PROJECTILE],
					blaster_projectile_spawn_transform,
					_primary_projectile_scale,
					_primary_attack_damage_component.get_path(),
					Utils.CollisionLayers.TEAM_PLAYER)

## Do a secondary attack
func doSecondaryAttack() -> void:
	# NOTE: Implement in each child weapon type
	pass

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
