extends Node

var console: Node  # Reference to DeveloperConsole

func run(args: Array) -> void:
	console.add_output("Exiting game...")
	console.get_tree().quit()  # Closes the game
