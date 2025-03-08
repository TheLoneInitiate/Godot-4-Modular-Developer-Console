extends Node

var console: Node  # Reference to DeveloperConsole

# Predefined directory for executable scripts
const SCRIPTS_DIR = "res://scripts/"

func run(args: Array) -> void:
	if args.size() < 2:
		console.add_output("Usage: exec <filename> [args...]")
		return
	
	var filename = args[1]
	var script_path = SCRIPTS_DIR + filename
	if not script_path.ends_with(".gd"):
		script_path += ".gd"  # Append .gd if omitted
	
	if not ResourceLoader.exists(script_path):
		console.add_output("Script not found in " + SCRIPTS_DIR + ": " + filename)
		return
	
	var script = load(script_path)
	if not script or not script is GDScript:
		console.add_output("Invalid GDScript file: " + script_path)
		return
	
	var instance = script.new()
	if not instance:
		console.add_output("Failed to instantiate script: " + script_path)
		return
	
	# Pass remaining args (if any) and call run() if it exists
	var script_args = args.slice(2)  # Everything after filename
	if instance.has_method("run"):
		var result = instance.run(script_args)
		if result != null:
			console.add_output("Script returned: " + str(result))
		else:
			console.add_output("Script executed: " + filename)
	else:
		console.add_output("Script executed (no run() method found): " + filename)
	
	# Clean up the instance if it's a Node
	if instance is Node:
		instance.queue_free()
	# If it's an Object, it will be garbage-collected automatically
