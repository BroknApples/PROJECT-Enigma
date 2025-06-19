
extends ProjectileType
class_name BlasterProjectile

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## BlasterProjectile
## 
## A simple laser shot, similar to "Star Wars" blaster shots
## Can change the color through the color parameter
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

@export var _color: Color = Color.BLUE: ## Color of the laser (Default is Color.BLUE)
	set(value):
		_color = value
		
		# TODO: Set the value in the editor, it was tweaking tho so i gave up on that for now
		# Maybe all scripts involved have to be a tool script? idk, seems like a hassle
		if (_initialized):
			_assignMeshInstanceColor()

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Assigns the mesh instance's mesh property's material's color
func _assignMeshInstanceColor() -> void:
	# If the node isn't ready, do not attempt an operation on a null instance
	if (!self.is_node_ready()):
		return
	
	_mesh_instance.mesh.material.albedo_color = _color

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# Call the super class's ready function
	super._ready()
	
	# Set the color
	self.call_deferred("_assignMeshInstanceColor")

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Set the color
func setColor(color: Color) -> void:
	_color = color

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
