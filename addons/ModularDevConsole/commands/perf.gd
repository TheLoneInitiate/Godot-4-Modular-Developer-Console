extends Control  # Using Control for drawing capabilities

var console: Node  # Reference to DeveloperConsole
var is_active: bool = false  # Track toggle state
var canvas_layer: CanvasLayer  # To ensure screen-space rendering

func run(args: Array) -> void:
	if not is_active:
		# Enable: Add to a CanvasLayer and start drawing
		if not is_inside_tree():
			canvas_layer = CanvasLayer.new()
			console.get_tree().root.add_child(canvas_layer)
			canvas_layer.add_child(self)
		is_active = true
		set_process(true)  # Enable processing for updates
		console.perf_hud = self  # Store reference in console
		console.add_output("Performance HUD: [color=green]ON[/color]")
	else:
		# Disable: Remove from scene and stop drawing
		is_active = false
		set_process(false)
		if is_inside_tree() and canvas_layer:
			canvas_layer.queue_free()  # Remove the CanvasLayer and its children
			canvas_layer = null
		console.perf_hud = null
		console.add_output("Performance HUD: [color=green]OFF[/color]")

func _ready() -> void:
	set_process(false)  # Start with processing off until enabled

func _process(delta: float) -> void:
	queue_redraw()  # Trigger redraw each frame to update stats

func _draw() -> void:
	if not is_active:
		return
	
	var viewport_size = get_viewport().get_visible_rect().size
	var font = ThemeDB.fallback_font  # Use default font
	var font_size = 16  # Adjust as needed
	
	var fps = Engine.get_frames_per_second()
	var process_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000  # ms
	var physics_time = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000  # ms
	
	var text_lines = [
		"[b]Performance Stats:[/b]",
		"[color=green]FPS:[/color] " + str(fps),
		"[color=green]Process Time:[/color] " + str(snapped(process_time, 0.1)) + " ms",
		"[color=green]Physics Time:[/color] " + str(snapped(physics_time, 0.1)) + " ms"
	]
	
	# Calculate text dimensions
	var line_height = font.get_height(font_size)
	var total_height = line_height * text_lines.size()
	var max_width = 0.0
	var stripped_lines = []  # Lines without BBCode for measurement and drawing
	for line in text_lines:
		var stripped = line.replace("[b]", "").replace("[/b]", "").replace("[color=green]", "").replace("[/color]", "")
		stripped_lines.append(stripped)
		var line_width = font.get_string_size(stripped, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size).x
		max_width = max(max_width, line_width)
	
	# Calculate position to fit within viewport (bottom-right with margin)
	var margin = Vector2(10, 10)  # Pixels from edges
	var text_size = Vector2(max_width, total_height)
	var start_pos = Vector2(
		viewport_size.x - text_size.x - margin.x,  # Right edge minus text width and margin
		viewport_size.y - text_size.y - margin.y   # Bottom edge minus text height and margin
	)
	
	# Ensure text stays within viewport bounds
	start_pos.x = max(0, min(start_pos.x, viewport_size.x - text_size.x))
	start_pos.y = max(0, min(start_pos.y, viewport_size.y - text_size.y))
	
	# Draw each line
	for i in range(text_lines.size()):
		var pos = start_pos + Vector2(0, i * line_height)
		var line = text_lines[i]
		var color = Color.WHITE
		if "[color=green]" in line:
			color = Color.GREEN
			line = line.replace("[color=green]", "").replace("[/color]", "")
		var is_bold = "[b]" in line
		if is_bold:
			line = line.replace("[b]", "").replace("[/b]", "")
		
		draw_string(font, pos, stripped_lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
		if is_bold:
			# Draw again slightly offset for a bold effect
			draw_string(font, pos + Vector2(1, 0), stripped_lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
