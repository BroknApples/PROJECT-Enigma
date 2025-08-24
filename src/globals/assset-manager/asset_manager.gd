extends Node

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## AssetManager Singleton
## 
## Defines all important or very large assets 
## used within the game
## 

# TODO: Figure out a better way to do this fr, this seems so tedious to add assets to this


# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

## Defines all assets as StringName types
## NOTE: Make sure to add the path and startup groups to the list "data" under the "Variables" section
class Assets:
	# UI
	const LOBBY_SCENE: StringName = &"LobbyScene"
	
	# World
	const CHUNK_DATA_SCENE: StringName = &"ChunkDataScene"
	
	# Player
	const PLAYER_CHARACTER_TYPE_SCENE: StringName = &"PlayerCharacterTypeScene"
	const PLAYER_INPUT_SCENE: StringName = &"PlayerInputScene"
	
	# Enemy
	
	# Weapons
	
	# Abilities
	
	# Projectiles
	const BLASTER_PROJECTILE_SCENE: StringName = &"BlasterProjectileScene"

## Defines groups of assets that determine when this asset should be loaded
class AssetGroups:
	const STARTUP: StringName = &"Startup" ## Load on startup of game

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

signal SIG_loaded_asset(asset_name: StringName, index: int, total_assets: int)

const PATH_INDEX: int = 0 ## Dictionary[key] : Array index 0 = path
const GROUPS_INDEX: int = 1 ## Dictionary[key] : Array index 1 = Array[AssetGroups]
const INSTANCE_INDEX: int = 2 ## Dictionary[key] : Array index 2 = instance of asset

## List of all assets
## { &"AssetName" : [&"AssetPath", [AssetGroups], AssetInstance] }s
var asset_data := {
	# UI
	Assets.LOBBY_SCENE: [&"res://src/ui/menus/lobby/lobby.tscn", [AssetGroups.STARTUP], null],
	
	# World
	Assets.CHUNK_DATA_SCENE: [&"res://src/core/world_controllers/chunk_data/chunk_data.tscn", [AssetGroups.STARTUP], null],
	
	# Player
	Assets.PLAYER_CHARACTER_TYPE_SCENE: [&"res://src/core/entities/player-character-type/player_character_type.tscn", [AssetGroups.STARTUP], null],
	Assets.PLAYER_INPUT_SCENE: [&"res://src/core/entities/player-character-type/player_input.tscn", [], null],
	
	# Enemy
	
	# Weapons
	
	# Abilities
	
	# Projectiles
	Assets.BLASTER_PROJECTILE_SCENE: [&"res://src/core/entities/projectiles/blaster_projectile/blaster_projectile.tscn", [], null],
	
}

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

## Check if an asset has a specific startup group
## @param arr: Array of startup groups to check
## @param target_group: Value to find
## @returns bool: True/False of existence
func _assetHasStartupGroup(arr: Array, target_group: StringName) -> bool:
	if (arr.has(target_group)):
		return true
	return false

## Check if an asset exists in this game
## @param asset_name: Name of the asset
## @returns bool: True/False of if the asset exists
func _assetExists(asset_name: StringName) -> bool:
	return asset_data.has(asset_name)

## Does the actual work of loading the asset given the name of the asset
## @param asset_name: Name of the asset
## @returns Resource: Asset resource
func _loadAssetInternal(asset_name: StringName) -> Resource:
	return load(String(getAssetPath(asset_name)))

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ 

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Loads important and large assets into the AssetManager singleton.
## This one is done at startup of the game
## @param asset_group: AssetGroup StringName to load
func loadAssetGroup(asset_group: StringName) -> void:
	Logger.logMsg("Loading Assets...", Logger.Category.RUNTIME)
	
	# Used to signal percetages of the loading
	var total_assets := asset_data.size() # How many assets are the in total to load
	# TODO: Get the actual total_assets for the given group
	
	var i := 0
	for key in asset_data.keys():
		# Only load if it has the correct asset group
		if (_assetHasStartupGroup(asset_data[key][GROUPS_INDEX], asset_group)):
			# Get path and load instance if its a scene
			asset_data[key][INSTANCE_INDEX] = _loadAssetInternal(key)
			
			# Emit the signal that an asset was loaded
			i += 1
			SIG_loaded_asset.emit(key, i, total_assets)
	
	Logger.logMsg("Assets Fully Loaded.", Logger.Category.RUNTIME)

## Unload a specific asset group
## @param asset_group: AssetGroup StringName to unload
func unloadAssetGroup(asset_group: StringName) -> void:
	Logger.logMsg("Unloading Assets...", Logger.Category.RUNTIME)
	
	for key in asset_data.keys():
		# Only load if it has the correct asset group
		if (_assetHasStartupGroup(asset_data[key][GROUPS_INDEX], asset_group)):
			asset_data[key][INSTANCE_INDEX] = null
	
	Logger.logMsg("Assets Fully Unloaded.", Logger.Category.RUNTIME)

## Loads important and large assets into the AssetManager singleton.
## This one is done at startup of the game
## @param asset_name: Asset StringName to load
func loadAsset(asset_name: StringName) -> void:
	Logger.logMsg("Loading Asset...", Logger.Category.RUNTIME)
	
	# If the asset exists, load it
	if (_assetExists(asset_name)):
		asset_data[asset_name][INSTANCE_INDEX] = _loadAssetInternal(asset_name)
		
		# Emit the signal that an asset was loaded
		SIG_loaded_asset.emit(asset_name, 1, 1)
	
	Logger.logMsg("Asset Loaded.", Logger.Category.RUNTIME)

## Unload a specific asset group
## @param asset_name: Asset StringName to unload
func unloadAsset(asset_name: StringName) -> void:
	Logger.logMsg("Unloading Asset...", Logger.Category.RUNTIME)
	
	# If the asset exists, unload it
	if (_assetExists(asset_name)):
		asset_data[asset_name][INSTANCE_INDEX] = null
	
	Logger.logMsg("Asset Unloaded.", Logger.Category.RUNTIME)

## Get the path to an asset
## @param asset_name: Name of the asset to get
## @returns StringName: The path to the asset
func getAssetPath(asset_name: StringName) -> StringName:
	return asset_data[asset_name][PATH_INDEX]

## Get a loaded asset
## @param asset_name: StringName of the asset
func getAsset(asset_name: StringName) -> Resource:
	var asset = asset_data.get(asset_name)[INSTANCE_INDEX]
	
	# Even if asset is null, it'll still return the proper value null
	return asset

## Load an asset, then return it without assigning the value in the dictionary
## @param asset_name: Name of the asset to get
## @returns Resource: The actual resource of the asset
func getAssetOneTime(asset_name: StringName) -> Resource:
	# If the asset is already loaded, just return the loaded asset
	if (isAssetLoaded(asset_name)):
		return getAsset(asset_name)
	
	# Since it isn't already loaded, load the asset and return
	# it without assigning it in the data dictionary
	return _loadAssetInternal(asset_name)

## Checks if a given asset is loaded
## @param asset_name: Name of the asset
## @returns bool: True/False of if the asset is loaded
func isAssetLoaded(asset_name: StringName) -> bool:
	return (asset_data.has(asset_name) && asset_data[asset_name][INSTANCE_INDEX] != null)

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
