@tool
extends Reticle
class_name CrosshairReticle

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## CrosshairReticle Class
## 
## A simple crosshair reticle
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

## The radius of the dot in the center of the screen
@export var _center_dot_radius: float: 
	set(value):
		# Value must be above 0
		value = clamp(value, 0.0, INF)
		_center_dot_radius = value

## How large is the gap between the center dot and the lines
## NOTE: Use ((_line_length / 2) + _center_gap) for the actual formula
@export var _center_gap: float = 15.0: 
	set(value):
		# Value must be above 0
		value = clamp(value, 0.0, INF)
		_center_gap = value

## How long are the directional lines
@export var _line_length: float = 30.0: 
	set(value):
		# Value must be above 0
		value = clamp(value, 0.0, INF)
		_line_length = value

## How wide are the directional lines
@export var _line_width: float = 6.0: 
	set(value):
		# Value must be above 0
		value = clamp(value, 0.0, INF)
		_line_width = value

## Size of the outline of the reticle
@export var _outline_size: float: 
	set(value):
		# Value must be above 0
		value = clamp(value, 0.0, INF)
		_outline_size = value

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

# TODO: Make setters and getters for stuff (here and in reticle.gd)

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
