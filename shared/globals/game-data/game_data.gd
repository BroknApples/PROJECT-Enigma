extends Node

# ************************************************************ #
#                       * File Purpose *                       #
# ************************************************************ #
## 
## GameData
## 
## Defines Data that every game instance will have, will be used
## on both the server and clients
##
## Holds server IP Addresses, Game Build Version, etc.
## 

# ************************************************************ #
#                     * Enums & Classes *                      #
# ************************************************************ #

# ************************************************************ #
#                        * Variables *                         #
# ************************************************************ #

# Overall Game Data
const GAME_VERSION: String = "pre-alpha v1.0.0"

# Server Data
const SERVER_MAXIMUM_PORT_NUMBER: int = 65535 ## Maximum possible port value
const SERVER_MAXIMUM_MAX_CLIENTS: int = 32 ## Maximum number of clients no matter what is set by the user

const SERVER_IP_ADDRESS: String = "127.0.0.1" ## Ip address of the server
const SERVER_PORT_NUMBER: int = 35693 ## Port number the server listens on
const SERVER_MAX_CLIENTS: int = 12 ## How many players can connect
const SERVER_RPC_ID: int = 1 ## Server @rpc ID should always be 1

# ************************************************************ #
#                     * Signal Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Private Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                     * Godot Functions *                      #
# ************************************************************ #

# ************************************************************ #
#                     * Public Functions *                     #
# ************************************************************ #

# ************************************************************ #
#                    * Unit Test Functions *                   #
# ************************************************************ #
