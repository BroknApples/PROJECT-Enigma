@tool
extends Node3D
class_name HealthComponent

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## HealthComponent
## 
## Defines a component that stores hit-points
##

# TODO: Implement an 'overhealth' mechanic;
# This mechanic allows a character to be healed for more than their maximum,
# the excess is converted into a shield-like health value
# Coloring: (if hp is green, overhealth is blue)

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

signal SIG_zero_health ## Emitted when health hits 0.0

## OPTIONAL Defense Component
@export var _defense_component: DefenseComponent = null

## Current Health
@export var _current_health: float:
	set(value):
		# Value must be above 0 AND under the maximum health value
		value = clamp(value, 0.0, _maximum_health)
		_current_health = value

## Maximum health
## This is the value actually showed
@export var _maximum_health: float = 0.0:
	set(value):
		# Value must be above 0
		value = clamp(value, 0.0, INF)
		_maximum_health = value
		
		# Ensure current health is within the expected range: (0.0, _maximum_health)
		# NOTE: This will simply call the set() function for the var to execute this
		_current_health = _current_health

## Maximum health
## This is an internal value used to calculate stats
@export var _base_maximum_health: float = 0.0:
	set(value):
		# Value must be above 0
		value = clamp(value, 0.0, INF)
		_base_maximum_health = value
		_recalculateMaximumHealth()

## Bonus Flat Maximum Health
## Simply added to maximum health calculation
@export var _bonus_flat_maximum_health: float = 0.0:
	set(value):
		# Value must be above 0
		value = clamp(value, 0.0, INF)
		_bonus_flat_maximum_health = value
		_recalculateMaximumHealth()

## Bonus Percent Maximum Health
## Multiplied with the base maximum health as a percentage and added
## Formula: ((_bonus_percent_maximum_health / 100.0) * _base_maximum_health)
@export var _bonus_percent_maximum_health: float = 0.0:
	set(value):
		# Value must be above 0
		value = clamp(value, 0.0, INF)
		_bonus_percent_maximum_health = value
		_recalculateMaximumHealth()

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Recalculate the maximum health stat displayed, this should only be called
## from within set() functions for the variables in this file
func _recalculateMaximumHealth() -> void:
	var calculated_health := _base_maximum_health
	
	# Add percentage increase
	calculated_health += ((_bonus_percent_maximum_health / 100.0) * _base_maximum_health)
	
	# Add flat value
	calculated_health += _bonus_flat_maximum_health
	
	# Set new value
	var old_maximum_health = _maximum_health
	_maximum_health = calculated_health
	
	# Add the gained health to current health so you aren't
	# just left at 5% hp if you gained a billion health
	if (old_maximum_health < _maximum_health):
		_current_health += _maximum_health - old_maximum_health

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# Setup metadata
	self.set_meta(Metadata.HEALTH_COMPONENT, true)
	
	# Set current health to maximum health initially
	_current_health = _maximum_health

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Take damage on this health node
## @param damage: Damage to be taken
func takeDamage(damage_data: DamageData) -> void:
	if (self.hasDefenseComponent()):
		# Apply defense since there is a component for it
		_current_health -= _defense_component.applyDefenseToDamage(damage_data.damage)
	else:
		# Do not apply defense since the component isn't initialized
		_current_health -= damage_data.damage
	
	# Check if health is at 0.0, if so, then emit the zero health signal
	if (_current_health == 0.0):
		SIG_zero_health.emit()

#***********************#
#******* GETTERS *******#
#***********************#

## Check if this health component has a defense component
## @returns bool: True/False of defense component's existence
func hasDefenseComponent() -> bool:
	return _defense_component != null

## Get the attached defense component node
## @retuns DefenseComponent: Defense component node referenced in this health component
func getDefenseComponent() -> DefenseComponent:
	return _defense_component

## Get the defense value of the defense component
## @returns float: Defense value of the defense component
func getDefenseComponentDefenseValue() -> float:
	# Defense component has not been initialized
	if (!self.hasDefenseComponent()): return 0.0
	
	return _defense_component.getDefenseValue()

## Get the current health of the health component
## @returns float: Current health of health component
func getCurrentHealth() -> float:
	return _current_health

## Get the maximum health of the health component
## @returns float: Maximum health of health component
func getMaximumHealth() -> float:
	return _maximum_health

## Get the base maximum health of the health component
## @returns float: Base maximum health of health component
func getBaseMaximumHealth() -> float:
	return _base_maximum_health

## Get the bonus flat maximum health of the health component
## @returns float: Bonus flat maximum health of health component
func getBonusFlatHealth() -> float:
	return _bonus_flat_maximum_health

## Get the bonus percent maximum health of the health component
## @returns float: Bonus percent maximum health of health component
func getBonusPercentHealth() -> float:
	return _bonus_percent_maximum_health

#***********************#
#******* SETTERS *******#
#***********************#

# Equality setters #

## NOTE: This should RARELY be used if at all
## Set the current health of the health component
## @param value: New current health of health component
func setCurrentHealth(value: float) -> void:
	_current_health = value

## NOTE: This should RARELY be used if at all
## Set the maximum health of the health component
## @param value: New maximum health of health component
func setMaximumHealth(value: float) -> void:
	_maximum_health = value

## NOTE: This should RARELY be used if at all
## Set the base maximum health of the health component
## @param value: New base maximum health of health component
func setBaseMaximumHealth(value: float) -> void:
	_base_maximum_health = value

## Set the bonus flat maximum health of the health component
## @param value: New bonus flat maximum health of health component
func setBonusFlatHealth(value: float) -> void:
	_bonus_flat_maximum_health = value

## Set the bonus percent maximum health of the health component
## @param value: New bonus percent maximum health of health component
func setBonusPercentHealth(value: float) -> void:
	_bonus_percent_maximum_health = value

# Addition setters #

## NOTE: Use a negative value to reduce the value
## Add current health to the health component
## @param value: Additional current health for the the health component
func addCurrentHealth(value: float) -> void:
	_current_health += value

## NOTE: Use a negative value to reduce the value
## Add maximum health to the health component
## @param value: Additional maximum health for the health component
func addMaximumHealth(value: float) -> void:
	_maximum_health += value

## NOTE: This should RARELY be used if at all
## NOTE: Use a negative value to reduce the value
## Add base maximum health to the health component
## @param value: Additional base maximum health for the health component
func addBaseMaximumHealth(value: float) -> void:
	_base_maximum_health += value

## NOTE: Use a negative value to reduce the value
## Add bonus flat maximum health to the health component
## @param value: Additional bonus flat maximum health for the health component
func addBonusFlatHealth(value: float) -> void:
	_bonus_flat_maximum_health += value

## NOTE: Use a negative value to reduce the value
## Add bonus percent maximum health to the health component
## @param value: Additional bonus percent maximum health for the health component
func addBonusPercentHealth(value: float) -> void:
	_bonus_percent_maximum_health += value

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
