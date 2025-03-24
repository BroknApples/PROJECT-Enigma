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

@onready var port_number_field = $"VBoxContainer/PortNumber LineEdit"
@onready var max_clients_field = $"VBoxContainer/MaxClients LineEdit"
@onready var play_button = $"VBoxContainer/Play Button"

@export var VERSION := "alpha v1.0.0"
var multiplayer_peer := ENetMultiplayerPeer.new()

const PORT_HARD_CAP := 65535 ## Maximum possible port value
var port_number := 52567 # Default port
const CLIENT_HARD_CAP := 100 ## Maximum number of clients no matter what is set by the user
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
		print("Entered invalid character in port number field.")
	elif (int_text > PORT_HARD_CAP || int_text < 0):
		print("Could not set port number out of range(0, ", PORT_HARD_CAP, ")")
		play_button.disabled = true
	else:
		port_number = int_text
		print("Set port number to: ", port_number)
		play_button.disabled = false
		# TODO: Fix bug 'Server.1'

## Set new maximum client count
func _on_max_clients_line_edit_text_changed(new_text: String) -> void:
	var formatted_text := _stringWithOnlyDigits(new_text)
	var int_text := formatted_text.to_int()
	
	if (formatted_text != new_text):
		max_clients_field.text = formatted_text
		print("Entered invalid character in max clients field.")
	elif (int_text > CLIENT_HARD_CAP || int_text < 0):
		print("Could not set max clients out of range(0, ", CLIENT_HARD_CAP, ")")
		play_button.disabled = true
	else:
		max_clients = int_text
		print("Set maximum clients: ", max_clients)
		play_button.disabled = false
		# TODO: Fix bug 'Server.1'

## Start server
func _on_play_button_pressed() -> void:
	multiplayer_peer.create_server(port_number, max_clients)

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
