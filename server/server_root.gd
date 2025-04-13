extends Node

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## Entry point for the Server Application
## 
## Holds application data and cross-checks with clients to ensure
## they are running the latest version
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

signal SIG_player_connected(peer_id, player_info) # When a player loads up the game in multiplayer mode
signal SIG_player_disconnected(peer_id) # When a player exits multiplayer mode
signal SIG_server_disconnected # When the server crashes

@onready var port_number_field := $"VBoxContainer/PortNumber LineEdit"
@onready var max_clients_field := $"VBoxContainer/MaxClients LineEdit"
@onready var play_button := $"VBoxContainer/Play Button"

const VERSION: String = "alpha v1.0.0" ## Current game version of the server
const PORT_HARD_CAP: int = 65535 ## Maximum possible port value
const CLIENT_HARD_CAP: int = 100 ## Maximum number of clients no matter what is set by the user

var e_net := ENetMultiplayerPeer.new()
var port_number := 27015 # Default Port Number -- Steam Multiplayer Port
var max_clients := 12 # Default maximum client count
var profile_id_counter := 0 # Ids for profiles, will read from a file for the max and increase as players are added

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

## Set new port number
func _on_port_number_line_edit_text_changed(new_text: String) -> void:
	var formatted_text = _stringWithOnlyDigits(new_text)
	var int_text := formatted_text.to_int()
	
	if (formatted_text != new_text):
		port_number_field.text = formatted_text
		Logger.logToTerminal("Entered invalid character in port number field.", Logger.Category.ERROR)
	elif (int_text > PORT_HARD_CAP || int_text < 0):
		Logger.logToTerminal("Could not set port number out of range(0, " + str(PORT_HARD_CAP) + ")", Logger.Category.ERROR)
		play_button.disabled = true
	else:
		port_number = int_text
		Logger.logToTerminal("Set port number to: " + str(port_number), Logger.Category.RUNTIME)
		play_button.disabled = false
		# TODO: Fix bug 'Server.1'

## Set new maximum client count
func _on_max_clients_line_edit_text_changed(new_text: String) -> void:
	var formatted_text := _stringWithOnlyDigits(new_text)
	var int_text := formatted_text.to_int()
	
	if (formatted_text != new_text):
		max_clients_field.text = formatted_text
		Logger.logToTerminal("Entered invalid character in max clients field.", Logger.Category.ERROR)
	elif (int_text > CLIENT_HARD_CAP || int_text < 0):
		Logger.logToTerminal("Could not set max clients out of range(0, " + str(CLIENT_HARD_CAP) + ")", Logger.Category.RUNTIME)
		play_button.disabled = true
	else:
		max_clients = int_text
		Logger.logToTerminal("Set maximum clients: " + str(max_clients), Logger.Category.RUNTIME)
		play_button.disabled = false
		# TODO: Fix bug 'Server.1'

## Start server
func _on_play_button_pressed() -> void:
	# Create server
	e_net.create_server(port_number, max_clients)
	var id = multiplayer.get_unique_id()
	set_multiplayer_authority(id)
	
	# Error creating server
	if (!is_multiplayer_authority()):
		Logger.logMsg("Could not establish Multiplayer Authority.", Logger.Category.ERROR)
		return # Early exit due to error
	
	Logger.logMsg("Server Started.", Logger.Category.RUNTIME)

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

func _ready() -> void:
	play_button.disabled = true

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #



func _stringWithOnlyDigits(str: String) -> String:
	var length = str.length()
	if length == 0: return "" # Empty text
	
	# Stop user from inputting anything other than numbers
	for i in range(length):
		if (str[i].to_int() == 0 && str[i] != '0'):
			return str.substr(0, i) + str.substr(i + 1, length)
	
	return str

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

func addNewlyConnectedProfile(profile_id: int) -> void:
	pass

func addPreviouslyConnectedProfile(profile_id: int) -> void:
	pass

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
