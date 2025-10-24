extends Node3D

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## WeaponInput
## 
## Defines input implementations for weapons. Conditionally activate
## this node if the owner is a player
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

@onready var _WEAPON: WeaponType = self.get_parent() ## Which weapon owns this script

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
func _spawnProjectileInternal(scene_path: StringName, node_transform: Transform3D, node_scale: Vector3, damage_component_path: NodePath) -> void:
	# Create an initializer array
	var damage_component = get_node_or_null(damage_component_path)
	var initialize_arr := [damage_component.get_path(), node_transform, node_scale]

	# Add to the proper location in the scene tree
	# GAME_ROOT.${WorldName}.ChunkData.Dynamic.Projectiles.${ProjectileNode}
	var chunk_data: ChunkData = Utils.getChunkDataNode()
	chunk_data.addDynamicProjectileObjectFromFilePath(scene_path, initialize_arr)

var atk_timer := 0.0

## The default input event responses
## @param event: InputEvent to check
func _defaultInputs() -> void:
	# PRIMARY ATTACK
	if (Input.is_action_pressed(Keybinds.ActionNames.PRIMARY_ATTACK)):
		if (atk_timer <= 0):
			_WEAPON.doPrimaryAttack()
			atk_timer = 0.5
	# SECONDARY ATTACK
	elif (Input.is_action_just_pressed(Keybinds.ActionNames.SECONDARY_ATTACK)):
		_WEAPON.doSecondaryAttack()

## Checks if the owning character body is the local player's character
func checkOwnerIsActivePlayer() -> bool:
	var weapon_owner: Node = _WEAPON.getOwningCharacter()
	
	# Checks if the owner is a player, and if so, are they the local player
	return weapon_owner.has_meta(Metadata.PLAYER_TYPE)

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _process(delta: float) -> void:
	atk_timer -= delta
	
	if (checkOwnerIsActivePlayer()):
		_defaultInputs()

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
