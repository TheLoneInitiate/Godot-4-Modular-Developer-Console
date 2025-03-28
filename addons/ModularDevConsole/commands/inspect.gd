extends Node

var console: Node  # Reference to DeveloperConsole

func run(args: Array) -> void:
	if args.size() < 2:
		console.add_output("Usage: inspect <node_name>")
		return
	
	var node_name = args[1]
	var root = console.get_node("/root")
	var target_node = find_node_by_name(root, node_name)
	
	if target_node:
		# Gather node details with styling
		var details = "Inspecting node: " + node_name + "\n"
		details += "- [color=green]Path[/color]: [color=red]" + str(target_node.get_path()) + "[/color]\n"
		details += "- [color=green]Parent[/color]: [color=white]" + (target_node.get_parent().name if target_node.get_parent() else "None") + "[/color]\n"
		
		# Position (2D or 3D based on node type)
		if target_node is Node2D:
			details += "- [color=green]Position[/color]: [color=white]" + str(target_node.position) + "[/color]\n"
			details += "- [color=green]Rotation[/color]: [color=white]" + str(target_node.rotation_degrees) + " degrees[/color]\n"
		elif target_node is Node3D:
			details += "- [color=green]Position[/color]: [color=white]" + str(target_node.position) + "[/color]\n"
			details += "- [color=green]Rotation[/color]: [color=white]" + str(target_node.rotation_degrees) + " degrees[/color]\n"
		
		# Children
		var children = target_node.get_children()
		details += "- [color=green]Child count[/color]: [color=white]" + str(children.size()) + "[/color]\n"
		if not children.is_empty():
			details += "- [color=green]Children[/color]: [color=white]" + ", ".join(children.map(func(n): return n.name)) + "[/color]\n"
		
		# Sample properties
		if target_node.has_method("get"):
			if target_node.get("speed") != null:
				details += "- [color=green]Speed[/color]: [color=white]" + str(target_node.get("speed")) + "[/color]\n"
			if target_node.get("health") != null:
				details += "- [color=green]Health[/color]: [color=white]" + str(target_node.get("health")) + "[/color]\n"
		
		console.add_output(details)
	else:
		console.add_output("Node '" + node_name + "' not found in scene tree.")

func find_node_by_name(node: Node, name: String) -> Node:
	if node.name.to_lower() == name.to_lower():
		return node
	for child in node.get_children():
		var found = find_node_by_name(child, name)
		if found:
			return found
	return null
