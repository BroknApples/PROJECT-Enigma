extends Node

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## AssetManager
## 
## Defines all important or very large assets 
## used within the game
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

## Defines all assets as StringName types
class AssetNames:
	# const someVar: StringName = &"some_name"
	pass

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

signal SIG_loaded_asset(asset_name: StringName, index: int)

## List of all assets
var assets: Dictionary = {
	# List assets here
	# { &"AssetName" : &"AssetPath" }
}

## How many assets are the in total to load
var total_assets = assets.size()

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

## Loads important and large assets into the AssetManager singleton
func loadAssets() -> void:
	Logger.logMsg("Loading Assets...", Logger.Category.RUNTIME)
	
	# Used to signal percetages of the loading
	var i = 0
	var size := assets.size()
	for key in assets.keys():
		# Get path and load instance if its a scene
		var path: StringName = assets[key]
		assets[key] = load(path).instantiate()
		
		i += 1
		SIG_loaded_asset.emit(key, i)
	
	Logger.logMsg("Assets Fully Loaded.", Logger.Category.RUNTIME)

## Get a loaded asset
## @param asset_name: StringName of the asset
func getAsset(asset_name: StringName) -> Variant:
	var asset = assets.get(asset_name)
	
	## Asset hasn't yet been loaded if it's 
	## still a StringName type
	if (asset is StringName):
		return null
	
	## Even if asset is null, it'll still return the proper value null
	return asset

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
