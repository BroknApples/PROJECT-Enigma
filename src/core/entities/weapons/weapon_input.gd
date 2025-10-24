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

# TESTING
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
