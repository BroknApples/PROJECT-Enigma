extends RigidBody3D
class_name ProjectileType

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## ProjectileType
## 
## Defines the base type of a projectile that can damage hitbox components
## 
## NOTE: This base class shouldn't be used to spawn a projectile. Use
## as a blueprint to create a child class.
##

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

@onready var _mesh_instance := $MeshInstance3D
@onready var _hitbox_component := $HitboxComponent
@onready var _health_component := $HealthComponent
@onready var _defense_component := $DefenseComponent
var _damage_component: DamageComponent = null
var _initial_transform: Transform3D ## Initial Transform3D data

## How fast does this projectile move
@export var _projectile_speed: float = 0.0:
	set(value):
		# Value must be greater than 0
		value = clamp(value, 0.0, INF)
		_projectile_speed = value

## How much is this projectile affected by gravity?
## 0 = Unaffected by gravity (Default)
## 0.5 = Half the gravity speed
## 1 = Normal gravity
## 2 = Double the gravity
@export var _gravity_scale: float = 0.0

## Up to how many targets can this one projectile hit?
@export var _maximum_contacts_reported: int = 1:
	set(value):
		# Value must be greater than one
		value = clamp(value, 1, INF)
		_maximum_contacts_reported = value

## How many targets has this projectile currently hit?
var _current_contact_count := 0

## Has this projectile been initialized using a .new() statement?
var _initialized := false

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

## Default method for detecting collision.
## Simply checks if the node can be damaged and collideable,
## if yes, it mdamages the node and disappears.
## @param body_rid: the RID of the other PhysicsBody3D or MeshLibrary's CollisionObject3D used by the PhysicsServer3D.
## @param body: the Node, if it exists in the tree, of the other PhysicsBody3D or GridMap.
## @param body_shape_index: the index of the Shape3D of the other PhysicsBody3D or GridMap used by the PhysicsServer3D.
##        Get the CollisionShape3D node with body.shape_owner_get_owner(body.shape_find_owner(body_shape_index)).
## @param local_shape_index: the index of the Shape3D of this RigidBody3D used by the PhysicsServer3D.
##        Get the CollisionShape3D node with self.shape_owner_get_owner(self.shape_find_owner(local_shape_index)).
func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	# Increment the amount of contacts this projectile has had
	_current_contact_count += 1
	
	# Projectile hit something that does not take damage/an object
	# the projectile cannot phase through
	# TODO: Implement
	
	# Projectile has hit its hit limit
	if (_current_contact_count >= _maximum_contacts_reported):
		self.queue_free()
	
	# Get the collision shape it collided with
	var collision_shape: CollisionShape3D = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	
	# Return if the collision shape does not have the hitbox component metadata
	if (!collision_shape.has_meta(Metadata.HITBOX_COMPONENT)):
		return
	
	# Rename the variable to avoid confusion
	var hitbox_component: HitboxComponent = collision_shape
	
	# Return if the hitbox component is not damageable
	if (!hitbox_component.isDamageable()):
		return
	
	# Since the collision shape is a hitbox component and is damageable, apply damage
	var damage_data := _damage_component.calculateDamage()
	hitbox_component.takeDamage(damage_data)

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Reparent the projectile to the prper node in the game world
## GAME_ROOT.${WorldName}.WorldData.Dynamic.Projectiles.${ProjectileNode}
func _reparentNodeToWorldData() -> void:
	var world_data := Utils.getWorldDataNode()
	
	# Remove the node from its current parent first
	self.get_parent().remove_child(self)
	
	# Add to proper section
	world_data.addDynamicProjectileObject(self)

#***********************************************#
#****# Common projectile physics processes #****#
#***********************************************#

## Physics process used for most projectiles. Simply moves the projectile
## in one direction (it can go up and down due to gravity or whatever though)
## Easy to reuse for most projectiles.
func _straightLineProjectilePhysicsProcess(delta: float) -> void:
	self.linear_velocity = -self.global_transform.basis.x * _projectile_speed

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# Do not allow if not initialized -> queue free
	if (!_initialized):
		self.call_deferred("queue_free")
		return
	
	# Setup metadata
	self.set_meta(Metadata.PROJECTILE_TYPE, true)
	
	# Setup the collision callback
	self.body_shape_entered.connect(_on_body_shape_entered)
	
	# Setup contact monitoring
	self.contact_monitor = true
	self.max_contacts_reported = _maximum_contacts_reported
	
	# Set gravity scale
	self.gravity_scale = _gravity_scale
	
	# Set data assigned in variables in "initialize()" to the newly created nodes
	_hitbox_component.setDamageComponent(_damage_component)
	self.transform = _initial_transform
	
	# Reparent node once it is properly initialized
	self.call_deferred("_reparentNodeToWorldData")

func _physics_process(delta: float) -> void:
	# NOTE: Default is a straight line projectile
	_straightLineProjectilePhysicsProcess(delta)

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #


## Initialize projectile
## @param damage_component: Damage component of the projectile,
## @param global_transform: 3D Transform data containing global position, rotation, etc.
func initialize(damage_component: DamageComponent, global_transform: Transform3D) -> void:
	# Set this projectile as initialized
	_initialized = true
	
	# Set damage component
	_damage_component = damage_component
	
	# Set transform data
	_initial_transform = global_transform

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
