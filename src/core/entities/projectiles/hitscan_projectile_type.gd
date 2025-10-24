@tool
extends ProjectileType
class_name HitscanProjectileType

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## HitscanProjectileType
## 
## Defines the base type of a projectile that can damage hitbox components.
## This projectile instantaneously travels through space and hits the first thing it collides with
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

@onready var _mesh_instance := $"."

@export var _collision_range: float = 200.0:
	set(value):
		# Value must be above 0.0
		value = clamp(value, 0.0, INF)
		
		_collision_range = value

## Up to how many targets can this one projectile hit?
@export var _maximum_contacts_reported: int = 1:
	set(value):
		# Value must be greater than one
		value = clamp(value, 1, INF)
		_maximum_contacts_reported = value

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

## Spawn the particles for this projectile.
## @param from: Vector3 of the origin of the shot
## @param to: Vector3 of the end-point of the shot
## @param hit_objcet: Did the projectile hit something?
func _spawnParticles(from: Vector3, to: Vector3, hit_object: bool) -> void:
	# TODO: Look into fixing the particle spawning issue, as right now, I have
	# to create an instance, change the values on that one, then make a new instance
	# where the values will actually be applied.
	# Perhaps look into somehow crafting the instance with a new mesh/process_material
	# as some parameter?
	
	# ALWAYS spawn the particle trail
	var particle_trail_scene := load(&"res://src/core/particles/hitscan_projectile/hitscan_projectile_trail.tscn")
	var setup_instance: HitscanProjectileTrail = particle_trail_scene.instantiate()
	setup_instance.setColor(Color.GREEN)
	setup_instance.setLength((from - to).length())
	setup_instance.setThickness(0.3)
	var particle_trail_instance = particle_trail_scene.instantiate()
	particle_trail_instance.setFromToTransform(from, to)
	Utils.getChunkDataNode().addParticleEffect(particle_trail_instance)
	
	if (hit_object):
		pass # TODO: Spawn like hit particles at that spot or something

## Default method for detecting collision.
## Simply checks if the node can be damaged and collideable,
## if yes, it damages the node and disappears.
func _checkForCollision() -> void:
	var space_state := self.get_world_3d().direct_space_state
	var from := self.global_position
	var direction := self.global_transform.basis.x.normalized()
	var remaining_distance := _collision_range
	var hit_count := 0
	var exclude := [self] # Prevent self-hit
	
	while (remaining_distance > 0) && (hit_count < _maximum_contacts_reported):
		var max_check_position := from + (direction * remaining_distance)
		
		var query = PhysicsRayQueryParameters3D.create(from, max_check_position)
		query.collide_with_areas = false
		query.collide_with_bodies = true
		
		# Setup collision masks - Default is terrain
		query.collision_mask = Utils.CollisionLayers.NON_GHOST_TERRAIN
		assignTeam(_team, query)
		
		query.exclude = exclude
		
		var result = space_state.intersect_ray(query)
		
		# Ray did not intersect with something
		var hit_object: bool = true
		if (!result):
			hit_object = false
			_spawnParticles(from, max_check_position, hit_object)
			break
		
		# NOTE: You can also spawn effects
		#spawn_impact_effect(result.position, result.normal)
		
		# Object it first collides with in this iteration
		var to: Vector3 = result.position
		var collider = result.collider
		exclude.append(collider)
		
		# Not a hitbox component, so stop the projectile completely
		if (!collider.has_meta(Metadata.HITBOX_COMPONENT)):
			_spawnParticles(from, to, hit_object)
			break
		
		# Rename the variable to avoid confusion
		var hitbox_component: HitboxComponent = collider
		
		# The hitbox component is not damageable, so go to the next loop-through
		if (!hitbox_component.isDamageable()):
			_spawnParticles(from, to, hit_object)
			break
			
		var damage_data := _damage_component.calculateDamage()
		hitbox_component.takeDamage(damage_data)
		hit_count += 1
		
		# Step forward slightly past the collision point to avoid hitting same surface
		var hit_pos: Vector3 = result.position
		from = hit_pos + direction * 0.01
		remaining_distance -= global_position.distance_to(hit_pos)
		
		# Draw the particle ray if this is the last loop
		if (remaining_distance <= 0) || (hit_count >= _maximum_contacts_reported):
			_spawnParticles(from, to, hit_object)
	
	# Despawn after processing all potential collisions
	_despawnProjectile()

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Wrapper function to queue free this projectile
func _despawnProjectile() -> void:
	# Despawn over time
	# TODO: Implement a fading projectile look or something
	Utils.sleep(0.8)
	
	# Free the UUID
	UUID.freeUuid(self.get_meta(Metadata.UUID))
	
	# Delete the node
	self.queue_free()

## Set the scale of the projectiile
## @param value: Scale to set the mesh/collision shape to0
func _setScale(value: Vector3) -> void:
	_mesh_instance.scale = value

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# Setup metadata
	self.set_meta(Metadata.PROJECTILE_TYPE, true)
	
	# Wait until the node is initialized.
	if (!_initialized):
		await self.SIG_initialized
	
	# Apply the node_path to the UUID dictionary
	UUID.assignNodeToDictionary(Utils.getNodePath(self), self.get_meta(Metadata.UUID))
	
	# Set transform data
	self.global_transform = _initial_transform_data
	
	# Disable the visibility of the mesh, it should NEVER be visible, just helps out in the editor ig
	self.visible = false
	
	# Set scale
	self._setScale(_initial_scale)
	
	# Now that everything is set up and the object is in the world, check for collision
	_checkForCollision()

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
