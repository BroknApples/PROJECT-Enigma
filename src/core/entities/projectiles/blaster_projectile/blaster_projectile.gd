
extends TravelProjectileType
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

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Assigns the mesh instance's mesh property's material's color
## @param wait_until_initialization: Should the function wait until
## the projectile has called "initialize" before continuing, or just give up?
func _applyColorToMesh(wait_until_initialization: bool = true) -> void:
	# Wait until the object is initialized
	if (wait_until_initialization && !_initialized):
		await self.SIG_initialized
	
	# If the node isn't ready, do not attempt an operation on a null instance
	if (!self.is_node_ready()):
		return
	
	_mesh_instance.mesh.material.albedo_color = _color

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# Call the super class's ready function
	await super._ready()
	
	# Set the color
	self.call_deferred(&"_applyColorToMesh")

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Set the color
func setColor(color: Color) -> void:
	_color = color

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
