extends ProjectileType
class_name TravelProjectileType

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## TravelProjectileType
## 
## Defines the base type of a projectile that can damage hitbox components.
## This projectile travels through the air with some velocity and movement method.
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

## How long can this entity survive in the game world
@export var _maximum_lifetime: float = 30.0:
	set(value):
		# Value must be greater than 0 and less than the inactive entity despawn time
		value = clamp(value, 0.0, Utils.INACTIVE_ENTITY_DESPAWN_TIME)
		_maximum_lifetime = value

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
	# Ignore collision with your own team's projectiles
	
	_current_contact_count += 1
	
	# Projectile has hit its hit limit
	if (_current_contact_count >= _maximum_contacts_reported):
		# Remove _despawnProjectile() function from the event scheduler
		EventScheduler.erase(Callable(_despawnProjectile))
		
		# Free resources
		_despawnProjectile()
	
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

## Wrapper function to queue free this projectile
func _despawnProjectile() -> void:
	# Free the UUID up
	UUID.freeUuid(self.get_meta(Metadata.UUID))
	
	# Delete the node
	self.queue_free()

## Set the scale of the projectiile
## @param value: Scale to set the mesh/collision shape to0
func _setScale(value: Vector3) -> void:
	Utils.safelyScaleNode(_mesh_instance, value)
	Utils.safelyScaleNode(_hitbox_component, value)

#*************************#
#**# Common Projectile #**#
#**# Physics Processes #**#
#*************************#

## Physics process used for most projectiles. Simply moves the projectile
## in one direction (it can go up and down due to gravity or whatever though)
## Easy to reuse for most projectiles.
func _straightLineProjectilePhysicsProcess(delta: float) -> void:
	self.linear_velocity = self.global_transform.basis.x * _projectile_speed

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# Setup metadata
	self.set_meta(Metadata.PROJECTILE_TYPE, true)
	
	# Wait until the node is initialized. NOTE: Disables processing until it is initialized
	await Utils.disableProcessingUntilInitialized(self)
	
	# Setup team
	self.assignTeam(_team)
	
	# Apply the node_path to the UUID dictionary
	UUID.assignNodeToDictionary(Utils.getNodePath(self), self.get_meta(Metadata.UUID))
	
	# Add the despawning function to the event scheduler to
	# despawn the projectile if its lifetime exceeds it limit
	EventScheduler.pushOneTimeEvent(Callable(_despawnProjectile), Clock.secondsToMilliseconds(_maximum_lifetime))
	
	# Setup the collision callback
	self.body_shape_entered.connect(_on_body_shape_entered)
	
	# Setup contact monitoring
	self.contact_monitor = true
	self.max_contacts_reported = _maximum_contacts_reported
	
	# Set gravity scale
	self.gravity_scale = _gravity_scale
	
	# Set data assigned in variables in "initialize()" to the newly created nodes
	_hitbox_component.setDamageComponent(_damage_component)
	
	# Set transform data
	self.global_transform = _initial_transform_data
	
	# Set scale
	_setScale(_initial_scale)

func _physics_process(delta: float) -> void:
	# NOTE: Default is a straight line projectile
	_straightLineProjectilePhysicsProcess(delta)

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
