@tool
extends Node3D
class_name DefenseComponent

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## DefenseComponent
## 
## Defines a component that stores a defense
## value which mitigates damage taken
##
## NOTE:
## Defense Formula: (Damage Taken = Original Damage * (_DEFENSE_SCALER / (_DEFENSE_SCALER + Defense)))
##

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

## Scales how effective defense stats are
##
## NOTE: Higher = less mitigation per defense stat
##
## NOTE: Whatever value is inputted here is the defense 
##       value in which you get 50% dmg reduction
const _DEFENSE_SCALER: int = 300
# Calculated values for scaler = 300:
#
# Defense	Scaler (300 / (300 + D))	% Damage Taken	% Mitigated
# 0			300 / 300 = 1.000			100%			0%
# 50		300 / 350 ≈ 0.857			85.7%			14.3%
# 100		300 / 400 = 0.750			75.0%			25.0%
# 150		300 / 450 ≈ 0.667			66.7%			33.3%
# 200		300 / 500 = 0.600			60.0%			40.0%
# 250		300 / 550 ≈ 0.545			54.5%			45.5%
# 300		300 / 600 = 0.500			50.0%			50.0%
# 350		300 / 650 ≈ 0.462			46.2%			53.8%
# 400		300 / 700 ≈ 0.429			42.9%			57.1%
# 450		300 / 750 = 0.400			40.0%			60.0%
# 500		300 / 800 = 0.375			37.5%			62.5%

## Defense value
## This is the value actually showed
@export var _defense: float = 0.0:
	set(value):
		# Value must be above 0
		value = clamp(value, 0.0, INF)
		_defense = value

## Base defense
## This is an internal value used to calculate stats
@export var _base_defense: float = 0.0:
	set(value):
		# Value must be above 0
		value = clamp(value, 0.0, INF)
		_base_defense = value
		_recalculateDefense()

## Bonus Flat Defense
## Simply added to defense calculation
@export var _bonus_flat_defense: float = 0.0:
	set(value):
		# Value must be above 0
		value = clamp(value, 0.0, INF)
		_bonus_flat_defense = value
		_recalculateDefense()

## Bonus Percent Defense
## Multiplied with the base defense as a percentage and added
## Formula: ((_bonus_percent_defense / 100.0) * _base_defense)
@export var _bonus_percent_defense: float = 0.0:
	set(value):
		# Value must be above 0
		value = clamp(value, 0.0, INF)
		_bonus_percent_defense = value
		_recalculateDefense()

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Recalculate the defense stat displayed, this should only be called
## from within set() functions for the variables in this file
func _recalculateDefense() -> void:
	var calculated_defense := _base_defense
	
	# Add percentage increase
	calculated_defense += ((_bonus_percent_defense / 100.0) * _base_defense)
	
	# Add flat value
	calculated_defense += _bonus_flat_defense
	
	# Set new value
	_defense = calculated_defense

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# Setup metadata
	self.set_meta(Metadata.DEFENSE_COMPONENT, true)

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Apply the defense value to a damage value
## @param damage: Damage to be recalculated
## @returns float: New damage value with defense mitigation applied
func applyDefenseToDamage(damage: float) -> float:
	# Apply defense formula
	var calculated_damage = damage * (_DEFENSE_SCALER / (_DEFENSE_SCALER + _defense))
	
	# Return calculated value
	return calculated_damage

#***********************#
#******* GETTERS *******#
#***********************#

## Get the defense of the defense component
## @returns float:  defense of defense component
func getDefenseValue() -> float:
	return _defense

## Get the base defense of the defense component
## @returns float: Base defense of defense component
func getBaseDefense() -> float:
	return _base_defense

## Get the bonus flat defense of the defense component
## @returns float: Bonus flat defense of defense component
func getBonusFlatDefense() -> float:
	return _bonus_flat_defense

## Get the bonus percent efense of the defense component
## @returns float: Bonus percent defense of defense component
func getBonusPercentDefense() -> float:
	return _bonus_percent_defense

#***********************#
#******* SETTERS *******#
#***********************#

# Equality setters #

## NOTE: This should RARELY be used if at all
## Set the defense of the defense component
## @param value: New defense of defense component
func setDefense(value: float) -> void:
	_defense = value

## NOTE: This should RARELY be used if at all
## Set the base defense of the defense component
## @param value: New base defense of defense component
func setBaseDefense(value: float) -> void:
	_base_defense = value

## Set the bonus flat defense of the defense component
## @param value: New bonus flat defense of defense component
func setBonusFlatDefense(value: float) -> void:
	_bonus_flat_defense = value

## Set the bonus percent defense of the defense component
## @param value: New bonus percent defense of defense component
func setBonusPercentDefense(value: float) -> void:
	_bonus_percent_defense = value

# Addition setters #

## NOTE: Use a negative value to reduce the value
## Add defense to the defense component
## @param value: Additional defense for the defense component
func addDefense(value: float) -> void:
	_defense += value

## NOTE: This should RARELY be used if at all
## NOTE: Use a negative value to reduce the value
## Add base defense to the defense component
## @param value: Additional base defense for the defense component
func addBaseDefense(value: float) -> void:
	_base_defense += value

## NOTE: Use a negative value to reduce the value
## Add bonus flat defense to the defense component
## @param value: Additional bonus flat defense for the defense component
func addBonusFlatDefense(value: float) -> void:
	_bonus_flat_defense += value

## NOTE: Use a negative value to reduce the value
## Add bonus percent defense to the defense component
## @param value: Additional bonus percent defense for the defense component
func addBonusPercentDefense(value: float) -> void:
	_bonus_percent_defense += value

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
