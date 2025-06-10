extends Node3D

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## TestWorld
## 
## World where I can test things, has many random features that exist on the map
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

@onready var world_data := $WorldData ## Premade class that defines where all the objects exist in the world

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	call_deferred("setCamera")

# TESTING
func setCamera():
	$WorldData/Entities/Players/PlayerCharacterType.getCameraPivot().setToCurrentCamera()
	$WorldData/Entities/Players/PlayerCharacterType.getCameraPivot().setToFirstPerson()
# TESTING

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
