@tool
extends CollisionShape3D
class_name HitboxComponent

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## HitboxComponent
## 
## Defines a hitbox for a game object
##
## NOTE: These should ONLY be used for objects you can
## interact with, do NOT use for environments and stuff
## 

# TODO: Bundle Health, hitbox, defense, attack, or whataver other components into
# one 'characterStatsComponent' for ease of use

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

signal SIG_take_damage_override(damage_data: DamageData) ## NOTE: Connect this to a function to override the 'takeDamage()' function

@export var _hitbox_shape: Shape3D: ## Actual hitbox shape data
	set(value):
		_hitbox_shape = value
		self.shape = value

@export var _health_component: HealthComponent = null ## Health component to take damage on

## How much damage is dealth when entering this body
## (Used for damage hitboxes or thorns-like effects)
@export var _damage_component: DamageComponent = null

var _damageable: bool ## Is this hitbox currently damageable? (Can this hitbox take damage)

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# TODO: Connect collision signal to function to apply damage when it enters an area
# ...... maybe, idk yet

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## The actual damage logic for hitboxes
## @param damage: Damage value to be taken
func _takeDamageInternal(damage_data: DamageData) -> void:
	# Health component has not been initialized || The hitbox is not currently damageable
	if (!self.hasHealthComponent() || !_damageable): return
	
	_health_component.takeDamage(damage_data)

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# Ensure shape is properly set
	if (_hitbox_shape != null):
		self.shape = _hitbox_shape
	
	# Setup metadata
	self.set_meta(Metadata.HITBOX_COMPONENT, true)

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Take damage on the health component object
## @param damage: Damage to take
func takeDamage(damage_data: DamageData) -> void:
	# NOTE: Call '_takeDamageInternal()' if you wish to reuse the
	# damage logic AND override the function to say, add a chat box
	# or say a voice line
	if (SIG_take_damage_override.get_connections().size() > 0):
		SIG_take_damage_override.emit(damage_data)
		return
	
	_takeDamageInternal(damage_data)

#
# GETTERS
#

## Check if this hitbox component has a health component
## @returns bool: True/False of health component's existence
func hasHealthComponent() -> bool:
	return _health_component != null

## Get the health component attached to this hitbox component
## @returns HealthComponent: The health component attached to this hitbox component
func getHealthComponent() -> HealthComponent:
	return _health_component

## Get the maximum health of the health component
## @returns float: Maximum health of health component
func getHealthComponentMaximumHealth() -> float:
	# Health component has not been initialized
	if (!self.hasHealthComponent()): return 0.0
	
	return _health_component.getMaximumHealth()

## Get the current health of the health component
## @returns float: Current health of health component
func getHealthComponentCurrentHealth() -> float:
	# Health component has not been initialized
	if (!self.hasHealthComponent()): return 0.0
	
	return _health_component.getCurrentHealth()

## Check if this hitbox component has a damage value
## @returns bool: True/False of damage value's existence
func hasDamageComponent() -> bool:
	return _damage_component != null

## Get the damage value that is taken when entering this body
## @returns float: Damage value
func getDamageValue() -> float:
	if (!self.hasDamageComponent()):
		# Damage component doesn't exist, so return 0
		return 0.0
	
	return _damage_component.getDamageValue()

## Check whether or not this hitbox component is damageable
## @returns bool: True/False of damageable state
func isDamageable() -> bool:
	return _damageable

#
# SETTERS
#

## Set a new hitbox shape
## @param value: New hitbox shape
func setHitboxShape(value: Shape3D) -> void:
	_hitbox_shape = value

## Set a new health component for this hitbox
## @param value: New health component object
func setHealthComponent(value: HealthComponent) -> void:
	_health_component = value

## Set a new damage component for this hitbox
## @param value: New damage component object
func setDamageComponent(value: DamageComponent) -> void:
	_damage_component = value

## Set a new damageable boolean value for this hitbox
## @param value: New boolean value for '_damageable'
func setDamageableState(value: bool) -> void:
	_damageable = value

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
