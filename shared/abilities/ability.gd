extends Node3D
class_name Ability

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Ability
## 
## Base class of all usable abilities
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

var _icon: Texture2D ## Icon texture to be displayed in the GUI
var _ability_name: String ## Name of the ability
var _ability_description: String ## Description of the ability

var _in_use: bool ## Is the current ability being used
var _cancellable: bool ## Can this ability be cancelled mid-cast?
var _total_cooldown: float ## Total cooldown of the ability in seconds
var _remaining_cooldown: float ## Current remaining cooldown of the ability in seconds
var _total_use_time: float ## How long does this ability take to finish, in seconds
var _remaining_use_time: float ## How long does this ability have left until it is finished being used
# TODO: May have to add use conditions array, define these conditions in some global script like 'CharacterState'
# thins like 'in-air', 'on-ground', 'has-jump-available', etc.
# NOTE: May want to use a dicitionary so they can hold specific values, not just boolean states
# needed for CharacterStats like 'has-jump: 3 left' or 'casting-ability: AbilityName'
# TODO: Once ELEMENTS are implement, add an element variable to the frame data or whatever along with
# a metadata tag of an Array[Element] or something, since some abilities may apply two elements at once

# Do not let any outside code access these. For this file's use only
var _use_speed_modifier: float ## Modifies how fast an ability is used by a percentage amount (e.g. 1.5 = 150% the speed)
# TODO: May need to implement some array that holds frame data for hitboxes while the abiliy is being cast
# will only actually be used on stuff like melee abilities and stuff, empty frame_data array if no damage can occur during cast
# Needed so that sword swings abilities or things of that nature can do damage mid-cast

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## This is what actually does the ability
## NOTE: Use @override to implement this in child types
func _doAbility() -> void:
	if (getRemainingUseTime() < 0.00):
		pass # Actually do whatever the ability should do now

# SETTERS

## Set the use speed modifier when using this ability
func _setUseSpeedModifier(use_speed_modifier: float) -> void:
	_use_speed_modifier = use_speed_modifier
	
# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _process(delta: float) -> void:
	if (_in_use):
		_remaining_use_time -= delta
		_doAbility()

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Set the ability to being used, it will apply this frame by
## calling _doAbility() in this function
## @param speed-modifier: Value that dictates how fast this ability will be used
## can be used to implement slow-down or speed-up effects later
func useAbility(speed_modifier: float = 1.00) -> void:
	_in_use = true
	_setUseSpeedModifier(speed_modifier)
	setRemainingUseTime(getTotalUseTime()) # Set remaining use time to the full amount
	_doAbility()
	# TODO: Do animation stuff here

# SETTERS
## Set Icon Texture of Ability
## @param: icon: New icon Texture2D
func setIcon(icon: Texture2D) -> void:
	_icon = icon

## Set if the current ability is being used at this time
## @param: use_state: New use state
func setUseState(use_state: bool) -> void:
	_in_use = use_state

## Set if the ability is cancellable at this time
## @param: cancellable_state: New cancellable state
func setCancellableState(cancellable_state: bool) -> void:
	_cancellable = cancellable_state

## Set the total cooldown of this ability in seconds
## @param: total_cooldown: New total cooldown in seconds
func setTotalCooldown(total_cooldown: float) -> void:
	_total_cooldown = total_cooldown

## Set the remaining cooldown of this ability in seconds
## @param: remaining_cooldown: New remaining cooldown in seconds
func setRemainingCooldown(remaining_cooldown: float) -> void:
	_remaining_cooldown = remaining_cooldown
	clamp(_remaining_cooldown, 0.00, _total_cooldown) # Ensure it does not fall below 0 or be above the maximum

func reduceCooldownByFlatValue(reduction: float) -> void:
	setRemainingCooldown(_remaining_cooldown - reduction)
	

## Reduce the remaining cooldown by a percentage value of the total cooldown
## @param percentage_reduction: By how much percent should the cooldown reduce of its total cooldown
## NOTE: percentage_reduction should be between 0 and 1
func reduceCooldownByPercentageOfTotal(percentage_reduction: float) -> void:
	clamp(percentage_reduction, 0.00, 1.00)
	setRemainingCooldown(_remaining_cooldown - (_total_cooldown * percentage_reduction))

## Reduce the remaining cooldown by a percentage value of the remaining cooldown
## @param percentage_reduction: By how much percent should the cooldown reduce of its remaining cooldown
## NOTE: percentage_reduction should be between 0 and 1
func reduceCooldownByPercentageOfRemaining(percentage_reduction: float) -> void:
	clamp(percentage_reduction, 0.00, 1.00)
	setRemainingCooldown(_remaining_cooldown - (_remaining_cooldown * percentage_reduction))

## Set the total time it takes to use the ability in seconds
## @param: total_use_time: New total use time in seconds
func setTotalUseTime(total_use_time: float) -> void:
	_total_use_time = total_use_time

## Set the remaining time in the ability usage in seconds
## @param: remaining_use_time: New remaining use time in seconds
func setRemainingUseTime(remaining_use_time: float) -> void:
	_remaining_use_time = remaining_use_time

# GETTERS

## Get Icon Texture of Ability
func getIcon() -> Texture2D:
	return _icon

## Is the current ability being used at this time?
func isInUse() -> bool:
	return _in_use

## Is the ability cancellable at this time?
func isCancellable() -> bool:
	return _cancellable

## Get the total cooldown of this ability in seconds
func getTotalCooldown() -> float:
	return _total_cooldown

## Get the remaining cooldown of this ability in seconds
func getRemainingCooldown() -> float:
	return _remaining_cooldown

## Get the total time it takes to use the ability in seconds
func getTotalUseTime() -> float:
	return _total_use_time

## Get the remaining time in the ability usage in seconds
func getRemainingUseTime() -> float:
	return _remaining_use_time

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
