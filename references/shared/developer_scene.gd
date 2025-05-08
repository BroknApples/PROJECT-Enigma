extends Node

# Launches some number of client instances of the game
# along with the dedicated server
const CLIENT_INSTANCES: int = 2
var outputs: Array[Array] = []
var threads: Array[Thread] = []

func _ready():
	# Declare Paths | NOTE: Change 'GODOT_PATH' to your local path to your Godot executable
	#const GODOT_PATH: String = "C:\\_MyFiles\\Godot_v4.3-stable_win64.exe\\Godot_v4.3-stable_win64.exe"
	const GODOT_PATH: String = "H:\\Godot-v4.3\\Godot_v4.3-stable_win64.exe"
	
	const SERVER_SCENE: String = "res://server/game_root.tscn"
	const CLIENT_SCENE: String = "res://client/game_root.tscn"
	
	# Initialize each index of the 'outputs' and 'threads' arrays
	for i in range(CLIENT_INSTANCES + 1):
		outputs.push_back([])
		threads.push_back(null)
	
	# Start each thread's instance
	for i in range(CLIENT_INSTANCES + 1):
		var scene := CLIENT_SCENE
		if (i == 0): scene = SERVER_SCENE # launch server
		var args = ["--scene", scene]
		
		threads[i] = Thread.new()
		var callable = Callable(self, "startInstance")
		callable = callable.bind(GODOT_PATH, args, i)
		threads[i].start(callable)
		print("Thread #%d start status: %d" % [i, int(threads[i].is_started())])
	
	# Join threads
	for i in range(CLIENT_INSTANCES + 1):
		if (threads[i] != null): threads[i].wait_to_finish()
	
	# Print to log files
	for i in range(CLIENT_INSTANCES + 1):
		# Get log path
		var log_path := "res://test-logs/"
		match(i):
			0:
				log_path += "server_log.txt"
			_:
				# Preprends #i_ to client logs to show how many were running
				# '#' = some number, 'i' - instance
				# at once; '2i_client1_log.txt' or '5i_client5_log.txt'
				log_path += str(CLIENT_INSTANCES) + "i_client" + str(i) + "_log.txt"
		
		for text in outputs[i]:
			Utils.writeToFile(log_path, text)
	
	# Quit game now that instances are closed
	call_deferred("exitGame")

func startInstance(godot_path, args, i: int) -> void:
	var result := OS.execute(godot_path, args, outputs[i])

	if (result == OK):
		print("Instance #%d launched!" % [i])
	else:
		print("Failed to launch instance #%d. Error code: " % [i], result)

## Exit main instance
func exitGame():
	get_tree().quit()
