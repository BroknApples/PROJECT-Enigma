extends Node

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Metadata Singleton
## 
## Defines all metadata tags used within the game.
##
##
## HOW TO USE:
##
## To add meta, call: 'set_meta(Metadata.xxx, true)'
## To check meta, call: 'has_meta(Metadata.xxx)'
##
##
## NOTE: These should always be 'StringName' variables
## 
	
# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

# METADATA TAGS
const HITBOX_COMPONENT: StringName = &"Hitbox" ## Hitbox node
const CHARACTER_TYPE: StringName = &"Hitbox" ## CharacterType Node
const PLAYER_TYPE: StringName = &"Player" ## PlayerCharacterType Node
const ENEMY_TYPE: StringName = &"Enemy" ## Enemy CharacterType Node

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

## Get a valid metadata key given a callable
## cannot use the str(callable) form since it contains '::'
## @param callable: Callable function to get string of
func createMetadataKeyFromCallable(callable: Callable) -> String:
	var key := "callable_" + str(callable.get_object().get_instance_id()) + "_" + callable.get_method()
	return key

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
