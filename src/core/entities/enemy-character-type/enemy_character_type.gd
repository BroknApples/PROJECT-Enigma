extends CharacterType
class_name EnemyCharacterType

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## EnemyCharacterType
## 
## Defines a basic implementation for enemies
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

## Defines the different categories of enemies
enum EnemyType {
	RANGED_SUPPORT, # Ranged healers and stuff
	RANGED_DEALER, # Gatling Gunners, Snipers, etc
	MELEE_SUPPORT, # Tanks, Melee Healers, etc.
	MELEE_DEALER, # Swordsman, Assassins, etc.
}

## Ranks of the enemies.
## Goon = Lowest tier, very common enemy
## Elite = Mid tier, common, yet strong enemy
## Miniboss = Low-high tier, rare, strong enemies, yet not the strongest
## Boss = Highest possible tier, very, very rare, super strong enemies
enum EnemyRank {
	GOON,
	ELITE,
	MINIBOSS,
	BOSS
}

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

@onready var _navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var _enemy_node_detection_area_3d := $EnemyNodeDetectionArea3D
@onready var _enemy_node_detection_collision_shape_3d := $EnemyNodeDetectionArea3D/CollisionShape3D

var _enemy_detection_radius: float = 20.0:
	set(value):
		value = clamp(value, 0.0, INF)
		_enemy_detection_radius = value

## Is this a goon, elite, miniboss, boss, or whatever
## Should only ever be set once, basically a constant.
var _enemy_rank: EnemyRank

## What is the type of enemy? Like dps, support, etc.
## NOTE: Can be set many times, like when a weapon is changed or form is changed
var _enemy_type: EnemyType

## How smart is the AI?
var _ai_difficulty: int:
	set(value):
		value = clamp(value, 1, 10)
		_ai_difficulty = value

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# AI Code #

## NOTE: Can be overriden to provide super specific unique enemy AI
## Chooses which AI code to run based on the AI's type and weapon equipped
func _runAi(delta: float) -> void:
	match(_enemy_type):
		EnemyType.RANGED_SUPPORT:
			_runRangedSupportEnemyAi(delta)
		EnemyType.RANGED_DEALER:
			_runRangedDealerEnemyAi(delta)
		EnemyType.MELEE_SUPPORT:
			_runMeleeSupportEnemyAi(delta)
		EnemyType.MELEE_DEALER:
			_runMeleeDealerEnemyAi(delta)

func _navigateToPosition(position: Vector3) -> void:
	# Set target position
	self._navigation_agent_3d.target_position = position
	
	# Apply movement
	var next_point = self._navigation_agent_3d.get_next_path_position()
	var direction = (next_point - global_transform.origin).normalized()
	var movement = direction * 100 * 0.167 #speed * delta
	self.global_translate(movement)

# TODO: AI Difficulty level (1-10) should change how well
# they kite (high difficulty = try to stay at max attack range)

## NOTE: Can be overriden to provide super specific unique enemy AI
func _runRangedSupportEnemyAi(delta: float) -> void:
	pass

## NOTE: Can be overriden to provide super specific unique enemy AI
func _runRangedDealerEnemyAi(delta: float) -> void:
	pass

## NOTE: Can be overriden to provide super specific unique enemy AI
func _runMeleeSupportEnemyAi(delta: float) -> void:
	pass

## NOTE: Can be overriden to provide super specific unique enemy AI
func _runMeleeDealerEnemyAi(delta: float) -> void:
	pass

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# Set metadata
	self.set_meta(Metadata.ENEMY_TYPE, true)
	
	# Call important functions in the base class
	await super._ready()

## Default physics interpretation for a CharacterType.
## Implements gravity
func _physics_process(delta: float) -> void:
	# Add gravity
	_runGravityPhysics(delta)
	
	# Run ai
	_runAi(delta)
	
	# Apply actual movement
	_character_body.move_and_slide()

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Initialize important values for character bodies...
## NOTE: You MUST ONLY run this when the character boy is located in
## one of the top level child nodes of the Entities node in a
## 'chunk_data' object
@rpc("any_peer", "call_local", "reliable")
func initialize(initialize_arr: Array) -> void:
	UUID.setMetadata(self, initialize_arr[UUID.INITIALIZER_ARRAY_UUID_INDEX])
	
	_ai_difficulty = initialize_arr[1]
	
	# Set this projectile as initialized
	_initialized = true
	SIG_initialized.emit()

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
