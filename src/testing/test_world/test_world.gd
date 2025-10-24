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
@onready var _chunk_data: ChunkData = $ChunkData ## Premade class that defines where all the objects exist in the world

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

# TODO: Set camera to 'player_id' pov

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Get the world data node for this world
## @returns ChunkData: ChunkData class type
func getChunkData() -> ChunkData:
	return _chunk_data

## Add a player to the player list in this world
func addPlayer() -> void:
	# Add the player
	await _chunk_data.addPlayerEntityFromFilePath(AssetManager.getAssetPath(AssetManager.Assets.PLAYER_CHARACTER_TYPE_SCENE))
	
	# TODO: Setup a player spawner position node, these will allow players to spawn at a position
	# if and only if there is no object present in some area3d node or something
	# TODO: Fix the 2nd player spawning in the ground(idk why it even happens tbh)

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
