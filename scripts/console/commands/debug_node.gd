extends Node

var console: Node  # Reference to DeveloperConsole
var debug_rays = []  # Track debug visuals
var target_node: Node = null  # Track the node we're visualizing

func run(args: Array) -> void:
	if args.size() < 2:
		console.add_output("Usage: toggle_raycasts <node_name>")
		return
	
	var node_name = args[1]
	var root = console.get_node("/root")
	target_node = find_node_by_name(root, node_name)
	
	if not target_node:
		console.add_output("Node '" + node_name + "' not found in the scene tree.")
		return
	
	var current_state = not debug_rays.is_empty()  # If debug rays exist, visibility is "on"
	var new_state = not current_state
	
	if new_state:
		# Enable: Add debug visuals and register for updates
		var raycasts = find_raycasts(target_node)
		if raycasts.is_empty():
			console.add_output("No raycasts found under '" + node_name + "'.")
			return
		
		for ray in raycasts:
			var debug_node = create_debug_visual(ray)
			if debug_node:
				debug_rays.append(debug_node)
				ray.add_child(debug_node)
				debug_node.owner = ray.owner
		
		console.register_active_command(self)
		console.add_output("Raycast visibility: [color=green]ON[/color] (" + str(debug_rays.size()) + " rays)")
	else:
		# Disable: Remove debug visuals and unregister
		for node in debug_rays:
			if is_instance_valid(node):
				node.queue_free()
		debug_rays.clear()
		target_node = null
		console.unregister_active_command(self)
		console.add_output("Raycast visibility: [color=green]OFF[/color]")

func update(delta: float) -> void:
	if not is_instance_valid(target_node) or debug_rays.is_empty():
		console.unregister_active_command(self)
		return
	
	# Update debug visuals in real-time
	var i = 0
	while i < debug_rays.size():
		var debug_node = debug_rays[i]
		if not is_instance_valid(debug_node):
			debug_rays.remove_at(i)
			continue
		
		var ray = debug_node.get_parent()
		if ray is RayCast2D:
			debug_node.points = [Vector2.ZERO, ray.target_position]
			if ray.is_colliding():
				debug_node.default_color = Color.RED  # Collision
			else:
				debug_node.default_color = Color.YELLOW  # No collision
		elif ray is RayCast3D:
			debug_node.mesh = create_line_mesh(ray.target_position)
			var mat = debug_node.material_override as StandardMaterial3D
			if ray.is_colliding():
				mat.albedo_color = Color.RED
			else:
				mat.albedo_color = Color.YELLOW
		i += 1

func find_node_by_name(node: Node, name: String) -> Node:
	if node.name.to_lower() == name.to_lower():
		return node
	for child in node.get_children():
		var found = find_node_by_name(child, name)
		if found:
			return found
	return null

func find_raycasts(node: Node) -> Array:
	var rays = []
	if node is RayCast2D or node is RayCast3D:
		rays.append(node)
	for child in node.get_children():
		rays.append_array(find_raycasts(child))
	return rays

func create_debug_visual(ray: Node) -> Node:
	if ray is RayCast2D:
		var line = Line2D.new()
		line.width = 2.0
		line.default_color = Color.YELLOW
		line.points = [Vector2.ZERO, ray.target_position]
		line.process_mode = Node.PROCESS_MODE_ALWAYS
		return line
	elif ray is RayCast3D:
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = create_line_mesh(ray.target_position)
		mesh_instance.material_override = StandardMaterial3D.new()
		mesh_instance.material_override.albedo_color = Color.YELLOW
		mesh_instance.material_override.flags_unshaded = true
		mesh_instance.process_mode = Node.PROCESS_MODE_ALWAYS
		return mesh_instance
	return null

func create_line_mesh(target: Vector3) -> Mesh:
	var mesh = ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_add_vertex(Vector3.ZERO)
	mesh.surface_add_vertex(target)
	mesh.surface_end()
	return mesh
