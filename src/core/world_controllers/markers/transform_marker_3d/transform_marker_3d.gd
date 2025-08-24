extends Node3D
class_name TransformMarker3D

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## TransformMarker3D
## 
## Defines a Node3D that functions similar to a Marker3D, but this
## one will rotate and move with the parent node.
##
## Use in place of Marker3D's when the object can move
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

func _ready() -> void:
	# Set node to invisible when the game starts
	#self.visible = false
	pass

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Get the local Transform3D of the marker
## @returns Transform3D: Local transform structure
func getLocalTransform() -> Transform3D:
	return self.transform

## Get the global Transform3D of the marker
## @returns Transform3D: Global transform structure
func getGlobalTransform() -> Transform3D:
	return self.global_transform

## Get the local position of the marker
## @returns Vector3: Local position structure
func getLocalPosition() -> Vector3:
	return self.position

## Get the global position of the marker
## @returns Vector3: Global position structure
func getGlobalPosition() -> Vector3:
	return self.global_position

## Get the local rotation of the marker
## @returns Vector3: Local rotation structure
func getLocalRotation() -> Vector3:
	return self.rotation

## Get the global rotation of the marker
## @returns Vector3: Global rotation structure
func getGlobalRotation() -> Vector3:
	return self.global_rotation

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
