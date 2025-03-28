extends Node

var console: Node  # Reference to DeveloperConsole

func run(args: Array) -> void:
	if not console.is_authenticated:
		console.add_output("Access denied. Please login with rcon_password first!")
		return
	console.add_output("Reloading current scene...")
	console.get_tree().reload_current_scene()  # Reloads the current scene
