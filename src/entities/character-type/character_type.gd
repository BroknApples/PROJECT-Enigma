extends Node3D

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## CharacterType
## 
## CharacterType is the parent of both Player AND Enemy types
##
## Defines essential methods and variables that ALL child-types
## will use, including: collision, abilities.
##
## NOTE: Unusable without adding CollisionShapes3D or CollisionPolygon3d
## in the Colliders node
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

@onready var colliders_array := $CharacterBody3D/Colliders

var _player_controlled := false

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

## Move the character type in a given Vector3 direction
## @param movement_input: Direction and velocity to move with
func move(movement_input: Vector3) -> void:
	pass

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
