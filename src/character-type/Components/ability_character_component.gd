extends Node3D
class_name CharacterComponent_Ability

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Ability Character Component
##
## Wrapper for character abilities
##
## _passive_abilities:  Passive Abilities
## _ability_1:          Basic Ability 1
## _ability_2:          Basic Ability 2
## _ability_3:          Signature Ability
## _ability_4:          Ultimate Ability
##
## NOTE
## Basic Ability 1 & Basic Ability 2 are NOT tied to the character class
## Passives, Signature, and Ultimate Abilities ARE tied to the character class
##
## Passives are always running, or at least always able to run. Stuff like: 'Can run on water', 'Has Two Jumps'
## Passives will be pickable by the user based on unlocked class pasives. Can have 2 max.
##
## Basic Abilities will be sorta like Echo Skill from WuWa(yes I know I reference WuWa
## a lot, it's just has good game design man).
##
## Signature is like a scenario-specific ability, e.g. 'Must be cast in air', 'Must be cast after jumping and sliding'
##
## Ultimate is just a class-specific ability that very powerful
##

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

# NOTE: The Array on eah ability(except passives) is used to signify different
# levels of an ability. If you've played WuWa think like: Aero Rover E, it has
# like 3 different casts of it. That is what the Array accomplishes
var _passive_abilities: Array[Ability] ## Passive Abilities
var _ability_1: Array[Ability] ## Basic Ability 1
var _ability_2: Array[Ability] ## Basic Ability 2
var _ability_3: Array[Ability] ## Signature Ability
var _ability_4: Array[Ability] ## Ultimate Ability

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



# GETTERS

# -- Passives -- #
## Get the passive abilties array
func getPassiveAbilities() -> Array[Ability]:
	return _passive_abilities
# -- Passives -- #

# -- Ability 1 -- #
## Get the ability_1 array
func getAbility1() -> Array[Ability]:
	return _ability_1

## Get the ability_1 array
func getAbilityOne() -> Array[Ability]:
	return _ability_1

## Get the ability_1 array
func getBasicAbility1() -> Array[Ability]:
	return _ability_1

## Get the ability_1 array
func getBasicAbilityOne() -> Array[Ability]:
	return _ability_1
# -- Ability 1 -- #

# -- Ability 2 -- #
## Get the ability_2 array
func getAbility2() -> Array[Ability]:
	return _ability_2

## Get the ability_2 array
func getAbilityTwo() -> Array[Ability]:
	return _ability_2

## Get the ability_2 array
func getBasicAbility2() -> Array[Ability]:
	return _ability_2

## Get the ability_2 array
func getBasicAbilityTwo() -> Array[Ability]:
	return _ability_2
# -- Ability 2 -- #

# -- Ability 3 -- #
## Get the ability_3 array
func getAbility3() -> Array[Ability]:
	return _ability_3

## Get the ability_3 array
func getAbilityThree() -> Array[Ability]:
	return _ability_3

## Get the ability_3 array
func getSignatureAbility() -> Array[Ability]:
	return _ability_3
# -- Ability 3 -- #

# -- Ability 4 -- #
## Get the ability_4 array
func getAbility4() -> Array[Ability]:
	return _ability_4

## Get the ability_4 array
func getAbilityFour() -> Array[Ability]:
	return _ability_4

## Get the ability_4 array
func getUltimateAbility() -> Array[Ability]:
	return _ability_4
# -- Ability 4 -- #

# SETTERS

# -- Passives -- #
## Set the passive abilties array
## @param passive_ablities: New passives array
func setPassiveAbilities(passive_abilities: Array[Ability]) -> void:
	# Invalid input
	if (passive_abilities.size() > 2):
		Logger.logMsg("Cannot assign more than two passives to an ability component.", Logger.Category.ERROR)
		return
	
	_passive_abilities = passive_abilities

## Add one ability to the passive abilites array
## @param passive_ablity: New passive ability to add to the array
func addPassiveAbility(passive_ability: Ability) -> void:
	# Invalid input
	if (_passive_abilities.size() > 2):
		Logger.logMsg("Cannot assign more than two passives to an ability component.", Logger.Category.ERROR)
		return
	
	_passive_abilities.push_back(passive_ability)
# -- Passives -- #

# -- Ability 1 -- #
## Set the ability_1 array
func setAbility1(ability_1: Array[Ability]) -> void:
	_ability_1 = ability_1

# TODO: -- Implement the rest of these below here --

## Set the ability_1 array
func setAbilityOne() -> void:
	_ability_1

## Set the ability_1 array
func setBasicAbilityOne() -> void:
	_ability_1
# -- Ability 1 -- #

# -- Ability 2 -- #
## Set the ability_2 array
func setAbility2() -> void:
	_ability_2

## Set the ability_2 array
func setAbilityTwo() -> void:
	_ability_2

## Set the ability_2 array
func setBasicAbilityTwo() -> void: 
	_ability_2
# -- Ability 2 -- #

# -- Ability 3 -- #
## Set the ability_3 array
func setAbility3() -> void:
	_ability_3

## Set the ability_3 array
func setAbilityThree() -> void:
	_ability_3

## Set the ability_3 array
func setSignatureAbility() -> void:
	_ability_3
# -- Ability 3 -- #

# -- Ability 4 -- #
## Set the ability_4 array
func setAbility4() -> void:
	_ability_4

## Set the ability_4 array
func setAbilityFour() -> void:
	_ability_4

## Set the ability_4 array
func setUltimateAbility() -> void:
	_ability_4
# -- Ability 4 -- #

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
