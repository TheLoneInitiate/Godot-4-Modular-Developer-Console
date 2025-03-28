extends Node2D

var console: Node  # Reference to the console, set when loaded
var tilemap_layer: TileMapLayer  # Reference to the TileMapLayer node
var grid_enabled: bool = false  # Tracks grid visibility state
var active_camera: Camera2D  # Reference to the active camera

func run(args: Array) -> void:
	if not console:
		print("Error: Console not initialized.")
		return
	
	# Find the TileMapLayer if not already set
	if not tilemap_layer:
		var root = console.get_node("/root")
		for node in console.get_all_nodes(root):
			if node is TileMapLayer:
				tilemap_layer = node
				break
		if not tilemap_layer:
			console.add_output("Error: No TileMapLayer found in the scene.")
			return
	
	# Find the active Camera2D if not already set
	if not active_camera:
		for node in console.get_all_nodes(console.get_node("/root")):
			if node is Camera2D and node.is_current():
				active_camera = node
				break
		if not active_camera:
			console.add_output("Error: No active Camera2D found in the scene.")
			return
	
	# Toggle grid visibility
	if args.size() == 1 or (args.size() == 2 and args[1].to_lower() == "toggle"):
		grid_enabled = !grid_enabled
	elif args.size() == 2:
		match args[1].to_lower():
			"on":
				grid_enabled = true
			"off":
				grid_enabled = false
			_:
				console.add_output("Usage: toggle_grid [on|off|toggle] (default: toggle)")
				return
	else:
		console.add_output("Usage: toggle_grid [on|off|toggle] (default: toggle)")
		return
	
	console.add_output("Grid visibility: " + ("on" if grid_enabled else "off"))
	
	# Add or remove this script as a child of TileMapLayer to handle drawing
	if grid_enabled and not tilemap_layer.is_ancestor_of(self):
		tilemap_layer.add_child(self)
		set_owner(tilemap_layer)
		# Ensure position matches TileMapLayer and updates
		global_position = tilemap_layer.global_position
		set_process(true)
	elif not grid_enabled and tilemap_layer.is_ancestor_of(self):
		tilemap_layer.remove_child(self)
		set_process(false)

func _process(_delta: float) -> void:
	if grid_enabled and tilemap_layer:
		# Keep position synced with TileMapLayer
		global_position = tilemap_layer.global_position
		queue_redraw()  # Trigger _draw() every frame when grid is enabled

func _draw() -> void:
	if not grid_enabled or not tilemap_layer or not active_camera:
		return
	
	var tile_size = tilemap_layer.tile_set.tile_size  # Vector2i
	
	# Get the visible area in world space using the active camera
	var cam_pos = active_camera.get_screen_center_position()
	var cam_size = get_viewport_rect().size / active_camera.zoom
	var top_left = cam_pos - cam_size / 2
	var bottom_right = cam_pos + cam_size / 2
	
	# Convert to tile coordinates in the TileMapLayer's local space
	var min_tile = tilemap_layer.local_to_map(tilemap_layer.to_local(top_left))
	var max_tile = tilemap_layer.local_to_map(tilemap_layer.to_local(bottom_right))
	
	# Ensure the grid covers at least the visible area, with some buffer
	min_tile -= Vector2i(1, 1)  # Add buffer to ensure full coverage
	max_tile += Vector2i(1, 1)
	
	# Draw vertical lines
	for x in range(min_tile.x, max_tile.x + 1):
		var start = Vector2(x * tile_size.x, min_tile.y * tile_size.y)
		var end = Vector2(x * tile_size.x, max_tile.y * tile_size.y)
		draw_line(start, end, Color.WHITE, 1.0)
	
	# Draw horizontal lines
	for y in range(min_tile.y, max_tile.y + 1):
		var start = Vector2(min_tile.x * tile_size.x, y * tile_size.y)
		var end = Vector2(max_tile.x * tile_size.x, y * tile_size.y)
		draw_line(start, end, Color.WHITE, 1.0)
