extends Node

var console: Node  # Reference to DeveloperConsole

func run(args: Array) -> void:
	if not console.is_authenticated:
		console.add_output("Access denied. Please enter the correct password with 'rcon_password' first.")
		return
	if args.size() < 2:
		console.add_output("Usage: print_vars <node>")
		return
	
	var node_name = args[1]
	var target_node = console.get_node("/root").find_child(node_name, true, false)
	if not target_node:
		console.add_output("Node '" + node_name + "' not found in the scene tree.")
		return
	
	if target_node.has_method("get_property_list"):
		var properties = target_node.get_property_list()
		var output = "[b]Exported variables for " + node_name + ":[/b]\n"
		var has_vars = false
		for prop in properties:
			if prop.usage & PROPERTY_USAGE_EDITOR:
				var value = target_node.get(prop.name)
				output += "- [color=red]" + prop.name + "[/color]: [color=green]" + str(value) + "[/color]\n"
				has_vars = true
		if not has_vars:
			output += "No exported variables found."
		console.add_output(output)
	else:
		console.add_output("No exported variables found for " + node_name + ".")
