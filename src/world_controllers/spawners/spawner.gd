extends Node3D

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Spawner
## 
## Base class of all spawner types, implements simply spawning
## methods
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

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

## Spawn a given object onto the position of the spawner
## @param object: Object to spawn
## @param offset: Offset from the center position of the spawner;
## default = (0, 1.5, 0), which is slightly above the spawner
func spawn(object: Resource, offset: Vector3 = Vector3(0, 1.5, 0)) -> void:
	var instance = object.instantiate()
	

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
