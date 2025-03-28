extends Node

var console: Node  # Reference to DeveloperConsole

func run(args: Array) -> void:
	if args.size() < 2:
		console.add_output("Usage: rcon_password <password>")
		return
	if args[1] == "gaben":  # Hardcoded for now; could be a const in DeveloperConsole
		console.is_authenticated = true
		console.add_output("Password accepted. Console access granted.")
	else:
		console.is_authenticated = false
		console.add_output("Invalid password.")
