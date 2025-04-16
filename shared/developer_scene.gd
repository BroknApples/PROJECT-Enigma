extends Node

# Launches some number of client instances of the game
# along with the dedicated server
const CLIENT_INSTANCES: int = 2
var outputs: Array[Array] = [[], [], []]
var threads: Array[Thread] = [null, null, null]

func _ready():	
	# NOTE: Change to your local path to Godot v4.3
	var godot_path = "C:\\_MyFiles\\Godot_v4.3-stable_win64.exe\\Godot_v4.3-stable_win64.exe"
	
	# Launch server
	var server_scene := "res://server/server_root.tscn"
	var client_scene := "res://client/client_root.tscn"
	
	for i in range(CLIENT_INSTANCES + 1):
		var scene := client_scene
		if (i == 0): scene = server_scene # launch server
		var args = ["--scene", scene]
		
		threads[i] = Thread.new()
		var callable = Callable(self, "startInstance")
		callable = callable.bind(godot_path, args, i)
		threads[i].start(callable)
		print("Thread #%d start status: %d" % [i, int(threads[i].is_started())])
	
	if (threads[0] != null): threads[0].wait_to_finish()
	if (threads[1] != null): threads[1].wait_to_finish()
	if (threads[2] != null): threads[2].wait_to_finish()
	
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

func startInstance(godot_path, args, i) -> void:
	var result = OS.execute(godot_path, args, outputs[i])

	if (result == OK):
		print("Instance #%d launched!" % [i])
	else:
		print("Failed to launch instance #%d. Error code: " % [i], result)

# Exit dummy Godot instance
func exitGame() -> void:
	get_tree().quit()
