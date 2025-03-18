extends Node

var console: Node  # Reference to DeveloperConsole
var debug_nodes = []  # Track debug visuals

func run(args: Array) -> void:
	# Toggle collision shape visibility in-game
	var current_state = not debug_nodes.is_empty()  # If debug nodes exist, visibility is "on"
	var new_state = not current_state
	
	if new_state:
		# Enable: Add debug visuals
		var collision_shapes = find_collision_shapes(console.get_node("/root"))
		if collision_shapes.is_empty():
			console.add_output("No collision shapes found in the scene tree.")
			return
		
		for shape in collision_shapes:
			var debug_node = create_debug_visual(shape)
			if debug_node:
				debug_nodes.append(debug_node)
				shape.add_child(debug_node)
				debug_node.owner = shape.owner  # Match ownership
		
		console.add_output("Collision shapes visibility: [color=green]ON[/color] (" + str(debug_nodes.size()) + " shapes)")
	else:
		# Disable: Remove debug visuals
		for node in debug_nodes:
			if is_instance_valid(node):
				node.queue_free()
		debug_nodes.clear()
		console.add_output("Collision shapes visibility: [color=green]OFF[/color]")

func find_collision_shapes(node: Node) -> Array:
	var shapes = []
	if node is CollisionShape2D or node is CollisionShape3D:
		shapes.append(node)
	for child in node.get_children():
		shapes.append_array(find_collision_shapes(child))
	return shapes

func create_debug_visual(shape: Node) -> Node:
	if shape is CollisionShape2D and shape.shape:
		var line = Line2D.new()
		line.width = 2.0
		line.default_color = Color.GREEN
		if shape.shape is RectangleShape2D:
			var extents = shape.shape.extents
			line.points = [
				Vector2(-extents.x, -extents.y),
				Vector2(extents.x, -extents.y),
				Vector2(extents.x, extents.y),
				Vector2(-extents.x, extents.y),
				Vector2(-extents.x, -extents.y)  # Close the loop
			]
		elif shape.shape is CircleShape2D:
			var radius = shape.shape.radius
			var points = []
			for i in range(32):  # Approximate circle with 32 points
				var angle = i * TAU / 32.0
				points.append(Vector2(cos(angle), sin(angle)) * radius)
			points.append(points[0])  # Close the loop
			line.points = points
		return line
	elif shape is CollisionShape3D and shape.shape:
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = create_wireframe_mesh(shape.shape)  # Pass the Shape3D
		mesh_instance.material_override = StandardMaterial3D.new()
		mesh_instance.material_override.albedo_color = Color.GREEN
		mesh_instance.material_override.flags_unshaded = true
		return mesh_instance
	return null

func create_wireframe_mesh(shape: Shape3D) -> Mesh:
	var mesh = ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	if shape is BoxShape3D:
		var size = shape.extents * 2  # extents is half the size
		var h = size / 2.0
		var vertices = [
			Vector3(-h.x, -h.y, -h.z), Vector3(h.x, -h.y, -h.z),
			Vector3(h.x, -h.y, -h.z), Vector3(h.x, h.y, -h.z),
			Vector3(h.x, h.y, -h.z), Vector3(-h.x, h.y, -h.z),
			Vector3(-h.x, h.y, -h.z), Vector3(-h.x, -h.y, -h.z),
			Vector3(-h.x, -h.y, h.z), Vector3(h.x, -h.y, h.z),
			Vector3(h.x, -h.y, h.z), Vector3(h.x, h.y, h.z),
			Vector3(h.x, h.y, h.z), Vector3(-h.x, h.y, h.z),
			Vector3(-h.x, h.y, h.z), Vector3(-h.x, -h.y, h.z),
			Vector3(-h.x, -h.y, -h.z), Vector3(-h.x, -h.y, h.z),
			Vector3(h.x, -h.y, -h.z), Vector3(h.x, -h.y, h.z),
			Vector3(h.x, h.y, -h.z), Vector3(h.x, h.y, h.z),
			Vector3(-h.x, h.y, -h.z), Vector3(-h.x, h.y, h.z)
		]
		for v in vertices:
			mesh.surface_add_vertex(v)
	
	elif shape is SphereShape3D:
		var radius = shape.radius
		for i in range(12):  # 12 segments for a simple wireframe
			var angle = i * TAU / 12.0
			mesh.surface_add_vertex(Vector3(cos(angle) * radius, sin(angle) * radius, 0))
			mesh.surface_add_vertex(Vector3(cos(angle + TAU / 12.0) * radius, sin(angle + TAU / 12.0) * radius, 0))
			mesh.surface_add_vertex(Vector3(0, cos(angle) * radius, sin(angle) * radius))
			mesh.surface_add_vertex(Vector3(0, cos(angle + TAU / 12.0) * radius, sin(angle + TAU / 12.0) * radius))
	
	elif shape is CapsuleShape3D:
		var radius = shape.radius
		var height = shape.height
		var half_height = height / 2.0
		var segments = 12  # Number of segments for circles
		
		# Top and bottom circles (cylindrical section)
		for i in range(segments):
			var angle = i * TAU / segments
			var next_angle = (i + 1) * TAU / segments
			
			# Top circle (at +half_height - radius)
			var top_center = Vector3(0, half_height - radius, 0)
			mesh.surface_add_vertex(top_center + Vector3(cos(angle) * radius, 0, sin(angle) * radius))
			mesh.surface_add_vertex(top_center + Vector3(cos(next_angle) * radius, 0, sin(next_angle) * radius))
			
			# Bottom circle (at -half_height + radius)
			var bottom_center = Vector3(0, -half_height + radius, 0)
			mesh.surface_add_vertex(bottom_center + Vector3(cos(angle) * radius, 0, sin(angle) * radius))
			mesh.surface_add_vertex(bottom_center + Vector3(cos(next_angle) * radius, 0, sin(next_angle) * radius))
		
		# Connecting lines between top and bottom
		for i in range(segments):
			var angle = i * TAU / segments
			var top_point = Vector3(cos(angle) * radius, half_height - radius, sin(angle) * radius)
			var bottom_point = Vector3(cos(angle) * radius, -half_height + radius, sin(angle) * radius)
			mesh.surface_add_vertex(top_point)
			mesh.surface_add_vertex(bottom_point)
		
		# Semi-circle arcs for top and bottom caps
		var cap_segments = 6  # Fewer segments for the caps
		for i in range(cap_segments):
			var angle = i * PI / cap_segments
			var next_angle = (i + 1) * PI / cap_segments
			
			# Top cap (in XZ plane)
			mesh.surface_add_vertex(Vector3(cos(angle) * radius, half_height - radius + sin(angle) * radius, 0))
			mesh.surface_add_vertex(Vector3(cos(next_angle) * radius, half_height - radius + sin(next_angle) * radius, 0))
			
			# Bottom cap (in XZ plane)
			mesh.surface_add_vertex(Vector3(cos(angle) * radius, -half_height + radius - sin(angle) * radius, 0))
			mesh.surface_add_vertex(Vector3(cos(next_angle) * radius, -half_height + radius - sin(next_angle) * radius, 0))
	
	elif shape is CylinderShape3D:
		var radius = shape.radius
		var height = shape.height
		var half_height = height / 2.0
		var segments = 12  # Number of segments for circles
		
		# Top and bottom circles
		for i in range(segments):
			var angle = i * TAU / segments
			var next_angle = (i + 1) * TAU / segments
			
			# Top circle
			mesh.surface_add_vertex(Vector3(cos(angle) * radius, half_height, sin(angle) * radius))
			mesh.surface_add_vertex(Vector3(cos(next_angle) * radius, half_height, sin(next_angle) * radius))
			
			# Bottom circle
			mesh.surface_add_vertex(Vector3(cos(angle) * radius, -half_height, sin(angle) * radius))
			mesh.surface_add_vertex(Vector3(cos(next_angle) * radius, -half_height, sin(next_angle) * radius))
		
		# Connecting lines
		for i in range(segments):
			var angle = i * TAU / segments
			mesh.surface_add_vertex(Vector3(cos(angle) * radius, half_height, sin(angle) * radius))
			mesh.surface_add_vertex(Vector3(cos(angle) * radius, -half_height, sin(angle) * radius))
	
	mesh.surface_end()
	return mesh
