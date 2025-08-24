@tool
extends Control
class_name Reticle

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Reticle Class
## 
## Defines the base class of all reticles
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

@export var _default_color: Color = Color.WHITE ## Color of the reticle when looking at non-enemies/friendlies
@export var _friendly_color: Color = Color.GREEN ## Color of the reticle when looking at non-enemies/friendlies
@export var _enemy_color: Color = Color.RED ## Color of the reticle when looking at non-enemies/friendlies
@export var _outline_color: Color = Color.BLACK ## Color of the outline of the reticle

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Actually set the colors of the reticles
func _applyColors() -> void:
	setDefaultColor(_default_color)
	setFriendlyColor(_friendly_color)
	setEnemyColor(_enemy_color)
	setOutlineColor(_outline_color)

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _process(delta: float) -> void:
	# TODO: Need to do some raycasting to figure out what the reticle is looking at
	pass

func _ready() -> void:
	# Set initial colors
	_applyColors()

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Set the color of the reticle when looking at nothing special
## @param value: New default color of the reticle
func setDefaultColor(_value: Color) -> void:
	# NOTE: Implement in child classes
	pass

## Set the color of the reticle when looking at a friendly unit
## @param value: New friendly color of the reticle
func setFriendlyColor(_value: Color) -> void:
	# NOTE: Implement in child classes
	pass

## Set the color of the reticle when looking at an enemy unit
## @param value: New enemy color of the reticle
func setEnemyColor(_value: Color) -> void:
	# NOTE: Implement in child classes
	pass

## Set the color of the outline on the reticle
## @param value: New outline color of the reticle
func setOutlineColor(_value: Color) -> void:
	# NOTE: Implement in child classes
	pass

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
