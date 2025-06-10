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

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

@export var hitbox_shape: Shape3D: ## Actual hitbox shape data
	set(value):
		hitbox_shape = value
		if (is_inside_tree()):
			self.shape = value
		else:
			await ready
			self.shape = value

@export var health_component: HealthComponent = null ## Health component to take damage on
@export var damage_value: float = 0.0: ## How much damage is dealth when entering this body (Used for damage hitboxes or thorns-like effects)
	set(value):
		# Only allow positive values
		if (value < 0.0):
			damage_value = 0.0
		else:
			damage_value = value

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

## Setup metadata
func _ready() -> void:
	# Ensure shape is properly set
	if (hitbox_shape != null):
		self.shape = hitbox_shape
	
	self.set_meta(Metadata.HITBOX_COMPONENT, true)

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Take damage on the health component object
## @param damage: Damage to take
func takeDamage(damage: float) -> void:
	# Health component has not been initialized
	if (!self.hasHealthComponent()): return
	
	health_component.takeDamage(damage)

## Check if this hitbox component has a health component
## @returns bool: True/False of health component's existence
func hasHealthComponent() -> bool:
	return health_component != null

## Check if this hitbox component has a damage value
## @returns bool: True/False of damage value's existence
func hasDamageValue() -> bool:
	return damage_value > 0.0

## Set a new hitbox shape
## @param new_hitbox: New hitbox shape
func setHitboxShape(new_hitbox_shape: Shape3D) -> void:
	hitbox_shape = new_hitbox_shape

## Set a new health component for this hitbox
## @param new_health_component: New health component object
func setHealthComponent(new_health_component: HealthComponent) -> void:
	health_component = new_health_component

## Get the health component attached to this hitbox component
## @returns HealthComponent: The health component attached to this hitbox component
func getHealthComponent() -> HealthComponent:
	return health_component

## Get the maximum health of the health component
## @returns float: Maximum health of health component
func getHealthComponentMaximumHealth() -> float:
	# Health component has not been initialized
	if (!self.hasHealthComponent()): return 0.0
	
	return health_component.getMaximumHealth()

## Get the current health of the health component
## @returns float: Current health of health component
func getHealthComponentCurrentHealth() -> float:
	# Health component has not been initialized
	if (!self.hasHealthComponent()): return 0.0
	
	return health_component.getCurrentHealth()

## Get the damage value that is taken when entering this body
## @returns float: Damage value
func getDamageValue() -> float:
	return damage_value

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
