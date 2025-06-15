@tool
extends Node3D
class_name DamageComponent

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## DamageComponent
## 
## Defines a component that stores damage values and ways for it to increase.
##
## Includes:
##
## Attack
## Damage Bonus%
## Element Damage Bonus%
## Critical Chance
## Critical Damage
##

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

# TODO: Implement Elements
#@export var _element_type: SomeGlobalScript.Elements (Should be an enum)

## Attack value
## This is the value actually showed
@export var _attack: float = 0.0:
	set(value):
		# Value must be above 0
		value = clamp(value, 0.0, INF)
		_attack = value

## Base attack
## This is an internal value used to calculate stats
@export var _base_attack: float = 0.0:
	set(value):
		# Value must be above 0
		value = clamp(value, 0.0, INF)
		_base_attack = value
		_recalculateAttack()

## Bonus Flat attack
## Simply added to attack calculation
@export var _bonus_flat_attack: float = 0.0:
	set(value):
		# Value must be above 0
		value = clamp(value, 0.0, INF)
		_bonus_flat_attack = value
		_recalculateAttack()

## Bonus Percent attack
## Multiplied with the base attack as a percentage and added
## Formula: ((_bonus_percent_attack / 100.0) * _base_attack)
@export var _bonus_percent_attack: float = 0.0:
	set(value):
		# Value must be above 0
		value = clamp(value, 0.0, INF)
		_bonus_percent_attack = value
		_recalculateAttack()

## Percent chance for a critical strike to occur.
## (Any value above 100.0 won't change anything)
@export var _critical_strike_chance: float = 0.0:
	set(value):
		# Value must be above 0
		value = clamp(value, 0.0, INF)
		_critical_strike_chance = value

## By what percentage is attack increased when a critical strike is triggered?
## Value must be above 100.0 since it is a percent increase, it obviously
## shouldn't lower the attack value
@export var _critical_strike_attack: float = 100.0:
	set(value):
		# Value must be above 0
		value = clamp(value, 100.0, INF)
		_critical_strike_chance = value

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Recalculate the attack stat displayed, this should only be called
## from within set() functions for the variables in this file
func _recalculateAttack() -> void:
	var calculated_attack := _base_attack
	
	# Add percentage increase
	calculated_attack += ((_bonus_percent_attack / 100.0) * _base_attack)
	
	# Add flat value
	calculated_attack += _bonus_flat_attack
	
	# Set new value
	_attack = calculated_attack

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# Setup metadata
	self.set_meta(Metadata.DAMAGE_COMPONENT, true)

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Rolls the attack value with critical chances and dmg% bonuses applied
func calculateDamage() -> float:
	# Start with attack as the base
	var calculated_damage := _attack
	
	# Apply damage modifiers
	# TODO: Implement (May need a reference to the parent node to
	# get its element bonus dmg%, general dmg%, along with debuffs as well
	
	# Apply critical strike attack first
	if (Utils.RNG.randf_range(0.0, 100.0) <= _critical_strike_chance):
		# Critical strike occurs
		calculated_damage *= _critical_strike_attack
	
	return calculated_damage

#***********************#
#******* GETTERS *******#
#***********************#

## Get the attack of the attack component
## @returns float:  attack of attack component
func getAttackValue() -> float:
	return _attack

## Get the base attack of the attack component
## @returns float: Base attack of attack component
func getBaseAttack() -> float:
	return _base_attack

## Get the bonus flat attack of the attack component
## @returns float: Bonus flat attack of attack component
func getBonusFlatAttack() -> float:
	return _bonus_flat_attack

## Get the bonus percent efense of the attack component
## @returns float: Bonus percent attack of attack component
func getBonusPercentAttack() -> float:
	return _bonus_percent_attack

#***********************#
#******* SETTERS *******#
#***********************#

# Equality setters #

## NOTE: This should RARELY be used if at all
## Set the attack of the attack component
## @param value: New attack of attack component
func setAttack(value: float) -> void:
	_attack = value

## NOTE: This should RARELY be used if at all
## Set the base attack of the attack component
## @param value: New base attack of attack component
func setBaseAttack(value: float) -> void:
	_base_attack = value

## Set the bonus flat attack of the attack component
## @param value: New bonus flat attack of attack component
func setBonusFlatAttack(value: float) -> void:
	_bonus_flat_attack = value

## Set the bonus percent attack of the attack component
## @param value: New bonus percent attack of attack component
func setBonusPercentAttack(value: float) -> void:
	_bonus_percent_attack = value

# Addition setters #

## NOTE: Use a negative value to reduce the value
## Add attack to the attack component
## @param value: Additional attack for the attack component
func addAttack(value: float) -> void:
	_attack += value

## NOTE: This should RARELY be used if at all
## NOTE: Use a negative value to reduce the value
## Add base attack to the attack component
## @param value: Additional base attack for the attack component
func addBaseAttack(value: float) -> void:
	_base_attack += value

## NOTE: Use a negative value to reduce the value
## Add bonus flat attack to the attack component
## @param value: Additional bonus flat attack for the attack component
func addBonusFlatAttack(value: float) -> void:
	_bonus_flat_attack += value

## NOTE: Use a negative value to reduce the value
## Add bonus percent attack to the attack component
## @param value: Additional bonus percent attack for the attack component
func addBonusPercentAttack(value: float) -> void:
	_bonus_percent_attack += value

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
