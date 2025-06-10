extends Node3D
class_name HealthComponent

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## HealthComponent
## 
## Defines a component that stores hp
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

signal SIG_no_health

## Maximum health
@export var max_health: float:
	set(value):
		# Value must be above 0
		if (value < 0.0):
			max_health = 0.0
		else:
			max_health = value

## Current Health
@export var current_health: float:
	set(value):
		# Value must be above 0
		if (value < 0.0):
			max_health = 0.0
		else:
			max_health = value

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

## Get the maximum health of the health component
## @returns float: Maximum health of health component
func getMaximumHealth() -> float:
	return max_health

## Get the current health of the health component
## @returns float: Current health of health component
func getCurrentHealth() -> float:
	return current_health

func takeDamage(damage: float) -> void:
	current_health -= damage
	if (current_health <= 0.0):
		SIG_no_health.emit()

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
