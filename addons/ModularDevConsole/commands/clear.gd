extends Node

var console: Node  # Reference to DeveloperConsole

func run(args: Array) -> void:
	console.output.clear()  # Clear the RichTextLabel output
	console.add_output("Console cleared.")
