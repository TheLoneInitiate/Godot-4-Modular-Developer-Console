extends Node

var console: Node  # Reference to DeveloperConsole

func run(args: Array) -> void:
	if args.size() < 2:
		console.add_output("Usage: list_groups <node_name>")
		return
	
	var node_name = args[1]
	var root = console.get_node("/root")
	var target_node = find_node_by_name(root, node_name)
	
	if not target_node:
		console.add_output("Node '" + node_name + "' not found in the scene tree.")
		return
	
	var groups = target_node.get_groups()
	if groups.is_empty():
		console.add_output("Node '" + node_name + "' is not in any groups.")
		return
	
	var output = "[b]Groups for node '" + node_name + "':[/b]\n"
	for group in groups:
		output += "- [color=green]" + group + "[/color]\n"
	console.add_output(output)

func find_node_by_name(node: Node, name: String) -> Node:
	if node.name.to_lower() == name.to_lower():
		return node
	for child in node.get_children():
		var found = find_node_by_name(child, name)
		if found:
			return found
	return null
