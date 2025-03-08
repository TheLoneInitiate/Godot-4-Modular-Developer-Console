extends Node

var console: Node  # Reference to DeveloperConsole

# Command descriptions (update as new commands are added)
const COMMAND_DESCRIPTIONS = {
	"rcon_password": "Authenticate with a password for restricted commands",
	"rcon_tree": "List nodes in the scene tree",
	"print_vars": "Lists all variables of desired node (e.g., print vars Player)",
	"clear": "Clear the console output",
	"set": "Set a property on a node (e.g., set Player speed 500)",
	"reload": "Reload the current scene",
	"load_scene": "Load a new scene (e.g., load_scene Main)",
	"inspect": "Show details of a node (e.g., inspect Player)",
	"exec": "Run a script from res://scripts/executable/ (e.g., exec test hello)",
	"save_log": "Save console output to a log file (e.g., save_log mylog)",
	"load_log": "Load a log file into the console (e.g., load_log mylog)",
	"exit": "Exit the game"
}

func run(args: Array) -> void:
	var help_text = "[b]Available commands:[/b]\n"
	for cmd in console.commands.keys():
		var desc = COMMAND_DESCRIPTIONS.get(cmd, "No description available")
		help_text += "- [color=green]" + cmd + "[/color]: [color=white]" + desc + "[/color]\n"
	console.add_output(help_text)
