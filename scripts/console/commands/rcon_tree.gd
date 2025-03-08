extends Node

var console: Node  # Reference to DeveloperConsole

func run(args: Array) -> void:
	if not console.is_authenticated:
		console.add_output("Access denied. Please enter the correct password with 'rcon_password' first.")
		return
	console.is_subtree_mode = false
	print_scene_tree()

func print_scene_tree() -> void:
	var root = console.get_node("/root")
	console.node_list.clear()
	collect_nodes_recursive(root, console.node_list)
	
	var output = "[b]Node Array in Scene Tree:[/b]\n"
	for i in range(console.node_list.size()):
		var node = console.node_list[i]
		var is_instance = not node.scene_file_path.is_empty()
		var line = "- [" + str(i) + "] [color=green]" + node.name + "[/color]"
		if is_instance:
			line += " [color=aqua](Instance)[/color]"
		output += line + "\n"
	
	output += "Enter the index of a node to view its subtree (e.g., '1'):"
	console.add_output(output)
	console.awaiting_selection = true

func print_node_subtree(node: Node) -> void:
	console.subtree_list.clear()
	collect_subtree_nodes(node, console.subtree_list, true)
	
	var output = "[b]Subtree Array for " + node.name + ":[/b]\n"
	for i in range(console.subtree_list.size()):
		var sub_node = console.subtree_list[i]
		var is_instance = not sub_node.scene_file_path.is_empty()
		var line = "- [" + str(i) + "] [color=green]" + sub_node.name + "[/color]"
		if is_instance:
			line += " [color=aqua](Instance)[/color]"
		output += line + "\n"
	
	output += "Enter the index of a node to view its subtree (e.g., '0'):"
	console.add_output(output)
	console.awaiting_selection = true

func collect_nodes_recursive(node: Node, node_list: Array[Node]) -> void:
	node_list.append(node)
	if node.scene_file_path.is_empty():
		for child in node.get_children():
			collect_nodes_recursive(child, node_list)

func collect_subtree_nodes(node: Node, subtree_list: Array[Node], is_root: bool = false) -> void:
	subtree_list.append(node)
	for child in node.get_children():
		if is_root:
			collect_subtree_nodes(child, subtree_list, false)
		elif node.scene_file_path.is_empty():
			collect_subtree_nodes(child, subtree_list, false)
