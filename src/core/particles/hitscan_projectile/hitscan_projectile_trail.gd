extends GPUParticles3D
class_name HitscanProjectileTrail

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## HitscanProjectileTrail
## 
## Defines an object that should represent the trail of the hitscan projectile
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

var _MESH: BoxMesh = self.draw_pass_1
var _PROCESS_MATERIAL: ParticleProcessMaterial = self.process_material

var _made_unique := false

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #
var color_idx = 0
func _process(delta: float) -> void:
	var new_color
	match(color_idx):
		0:
			new_color = Color.RED
		1:
			new_color = Color.BLUE
		2:
			new_color = Color.GREEN
	color_idx += 1
	if (color_idx > 2):
		color_idx = 0
	
	_MESH.material.albedo_color = new_color
	# If the particle is one shot, they await its lifetime and then remove from the tree
	if (self.one_shot):
		await Utils.sleep(self.lifetime)
		self.queue_free()

func _ready() -> void:
	self.one_shot = true

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## NOTE: MUST be called before ANYTHING else to get the expected result
## Makes the materials and meshes unique to this particle
func makeUnique() -> void:
	# Duplicate the entire draw_pass with its material in one go
	var new_draw_pass := self.draw_pass_1.duplicate(true)
	new_draw_pass.set_material(new_draw_pass.get_material().duplicate())
	
	# Apply duplicates
	self.draw_pass_1 = new_draw_pass
	self.process_material = self.process_material.duplicate()
	
	# Change flag value
	_made_unique = true

## NOTE: MUST be called before 'add_child'
## Set the alpha curve of the process material
## @param start: Starting value (Value at 0.0)
## @param end: Ending value (Value at 1.0)
## @param min: Minimum value
## @param max: Maximum value
func setAlphaCurve(start: float, end: float, min: float = 0.0, max: float = 1.0) -> void:
	# Won't change anything if the node is ready, so return
	if (self.is_node_ready()):
		return
	
	# Ensure the node is made unique before changing anything
	if (!_made_unique):
		self.makeUnique()
	
	var new_curve: Curve = Curve.new()
	
	# Set values
	new_curve.add_point(Vector2(0.0, start))
	new_curve.add_point(Vector2(1.0, end))
	new_curve.set_min_value(min)
	new_curve.set_max_value(max)
	
	_PROCESS_MATERIAL.alpha_curve.curve = new_curve

## NOTE: MUST be called before 'add_child'
## Change how long the particle will exist in the world.
## @param value: New lifetime of the particle
func setLifetime(value: float) -> void:
	# Won't change anything if the node is ready, so return
	if (self.is_node_ready()):
		return
	
	# Ensure the node is made unique before changing anything
	if (!_made_unique):
		self.makeUnique()
	
	self.lifetime = value

## NOTE: MUST be called before 'add_child'
## Set an entirely new material for the particle
## @param value: New material
func setMaterial(value: Material) -> void:
	# Won't change anything if the node is ready, so return
	if (self.is_node_ready()):
		return
	
	# Ensure the node is made unique before changing anything
	if (!_made_unique):
		self.makeUnique()
	
	_MESH.set_material(value)

## NOTE: MUST be called before 'add_child'
## Set the color of the projectile trail through
## the albedo_color property of its material
## @param value: New color of the particle
func setColor(value: Color) -> void:
	# Won't change anything if the node is ready, so return
	if (self.is_node_ready()):
		return
	
	# Ensure the node is made unique before changing anything
	if (!_made_unique):
		self.makeUnique()
	
	_MESH.material.albedo_color = value

## NOTE: MUST be called before 'add_child'
func setLength(length: float) -> void:
	# Won't change anything if the node is ready, so return
	if (self.is_node_ready()):
		return
	
	# Ensure the node is made unique before changing anything
	if (!_made_unique):
		self.makeUnique()
	
	_MESH.size.x = length

## NOTE: MUST be called before 'add_child'
## Places the particle in the world and resizes it based
## on where its going "to" and where its coming "from"
## @param from: Origin of the beam
## @param to: End-point of the beam
func setFromToTransform(from: Vector3, to: Vector3) -> void:
	# Won't change anything if the node is ready, so return
	if (self.is_node_ready()):
		return
	
	# Ensure the node is made unique before changing anything
	if (!_made_unique):
		self.makeUnique()
	
	var dir := (to - from) # Direction to orient node
	var midpoint := from + (dir / 2) # This is where the node should be placed in world space
	
	# Normalize direction for basis
	var x_axis := dir.normalized()
	var up := Vector3.UP
	
	# Prevent degenerate cross products if dir is vertical
	if abs(x_axis.dot(up)) > 0.999:
		up = Vector3.FORWARD  # fallback "up" vector
	
	# Form new basis
	var z_axis := x_axis.cross(up).normalized()
	var y_axis := z_axis.cross(x_axis).normalized()
	var rotated_basis := Basis(x_axis, y_axis, z_axis)
	
	# Set values
	var new_transform = Transform3D(rotated_basis, midpoint)
	self.transform = new_transform

## NOTE: MUST be called before 'add_child'
## NOTE: If planning on calling 'setFromToTransform()', call AFTER it is done
## Set the thickness of the 
func setThickness(value: float) -> void:
	# Won't change anything if the node is ready, so return
	if (self.is_node_ready()):
		return
	
	# Ensure the node is made unique before changing anything
	if (!_made_unique):
		self.makeUnique()
	
	_MESH.size.y = value
	_MESH.size.z = value

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
