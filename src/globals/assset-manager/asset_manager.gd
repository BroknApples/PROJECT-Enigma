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

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

## Defines all assets as StringName types
## Array index 0 = name
## Array index 1 = path
class Assets:
	const LobbyScene: Array[StringName] = [&"LobbyScene", &"res://src/menus/lobby/lobby.tscn"]
	const WorldData: Array[StringName] = [&"WorldData", &"res://src/world_controllers/world_data/world_data.tscn"]

## Defines groups of assets that determine when this asset should be loaded
class AssetGroups:
	const STARTUP: StringName = &"Startup" ## Load on startup of game

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

signal SIG_loaded_asset(asset_name: StringName, index: int, total_assets: int)

const NAME: int = 0 ## Index used in the Assets class for NAMES
const PATH: int = 1 ## Index used in the Assets class for PATHS

## List of all assets
var _assets: Dictionary = {
	# List assets here
	# { &"AssetName" : [&"AssetPath", AssetInstance, [AssetGroups]] }
	Assets.LobbyScene[0]: [Assets.LobbyScene[1], null, [AssetGroups.STARTUP]],
	Assets.WorldData[0]: [Assets.WorldData[1], null, [AssetGroups.STARTUP]],
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

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

## Loads important and large assets into the AssetManager singleton.
## This one is done at startup of the game
## @param asset_group: AssetGroup StringName to load
func loadAssetGroup(asset_group: StringName) -> void:
	Logger.logMsg("Loading Assets...", Logger.Category.RUNTIME)
	
	# Used to signal percetages of the loading
	var total_assets := _assets.size() # How many assets are the in total to load
	# TODO: Get the actual total_assets for the given group
	
	var i := 0
	for key in _assets.keys():
		# Only load if it has the "STARTUP" asset group
		if (_assetHasStartupGroup(_assets[key][2], asset_group)):
			# Get path and load instance if its a scene
			var path: StringName = _assets[key][0]
			_assets[key][1] = load(String(path))
			
			i += 1
			SIG_loaded_asset.emit(key, i, total_assets)
	
	Logger.logMsg("Assets Fully Loaded.", Logger.Category.RUNTIME)

## Unload a specific asset group
## @param asset_group: AssetGroup StringName to unload
func unloadAssetGroup(asset_group: StringName) -> void:
	Logger.logMsg("Unloading Assets...", Logger.Category.RUNTIME)
	
	for key in _assets.keys():
		# Only load if it has the "STARTUP" asset group
		if (_assetHasStartupGroup(_assets[key][2], asset_group)):
			_assets[key][1] = null
	
	Logger.logMsg("Assets Fully Unloaded.", Logger.Category.RUNTIME)

## Loads important and large assets into the AssetManager singleton.
## This one is done at startup of the game
## @param asset_name: Asset StringName to load
func loadAsset(asset_name: StringName) -> void:
	Logger.logMsg("Loading Asset...", Logger.Category.RUNTIME)
	
	# If the asset exists, load it
	if (_assets.has(asset_name)):
		var path: StringName = _assets[asset_name][0]
		_assets[asset_name][1] = load(String(path))
		
		SIG_loaded_asset.emit(asset_name, 1, 1)
	
	Logger.logMsg("Asset Loaded.", Logger.Category.RUNTIME)

## Unload a specific asset group
## @param asset_name: Asset StringName to unload
func unloadAsset(asset_name: StringName) -> void:
	Logger.logMsg("Unloading Asset...", Logger.Category.RUNTIME)
	
	# If the asset exists, unload it
	if (_assets.has(asset_name)):
		_assets[asset_name][1] = null
	
	Logger.logMsg("Asset Unloaded.", Logger.Category.RUNTIME)

## Get a loaded asset
## @param asset_name: StringName of the asset
func getAsset(asset_name: StringName) -> Resource:
	var asset = _assets.get(asset_name)[1]
	
	## Asset hasn't yet been loaded if it's 
	## still a StringName type
	if (asset is StringName):
		return null
	
	## Even if asset is null, it'll still return the proper value null
	return asset

## Checks if a given asset is loaded
## @param asset_name: Name of the asset
## @returns bool: True/False of if the asset is loaded
func isAssetLoaded(asset_name: StringName) -> bool:
	if (_assets.has(asset_name) && _assets[asset_name][1] != null):
		return true
	return false

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
