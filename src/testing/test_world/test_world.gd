extends Node3D

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## TestWorld
## 
## World where I can test things, has many random features that exist on the map
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

# TODO: Reformat world data to being the super class of all worlds
# Makes it easier to add objects to the world / use functions
@onready var _chunk_data: Array[ChunkData] = [] ## Defines where all the objects exist in the world for each chunk

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	# Set metadata
	self.set_meta(Metadata.WORLD_NODE, true)
	self.call_deferred("spawnEntities")
	
	# Add all chunks to the chunk_data array
	for child in self.get_children():
		_chunk_data.append(child)

# TODO: Set camera to 'player_id' pov

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Get the world data node for this world
## @returns ChunkData: ChunkData class type
func getChunkData() -> Array[ChunkData]:
	return _chunk_data

## Adds some random entities to the world
func spawnEntities() -> void:
	# Add the player
	var player = await _chunk_data[0].addPlayerEntityFromFilePath(AssetManager.getAssetPath(AssetManager.Assets.PLAYER_CHARACTER_TYPE_SCENE))
	var enemy = await _chunk_data[0].addEnemyEntityFromFilePath(AssetManager.getAssetPath(AssetManager.Assets.ENEMY_CHARACTER_TYPE_SCENE), [1])
	enemy.position.x += 10
	
	# TODO: Setup a player spawner position node, these will allow players to spawn at a position
	# if and only if there is no object present in some area3d node or something
	# TODO: Fix the 2nd player spawning in the ground(idk why it even happens tbh)

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
