extends Node

var console: Node  # Reference to DeveloperConsole

func run(args: Array) -> void:
	# Check if the command has valid arguments
	if args.size() > 1:
		console.add_output("Usage: fullscreen")
		return
	
	# Toggle fullscreen state
	var is_fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	is_fullscreen = !is_fullscreen
	
	if is_fullscreen:
		# Set to fullscreen mode
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.window_set_size(Vector2i(1920, 1080))
		console.add_output("Fullscreen: [color=green]ON[/color] (Resolution: " + str(DisplayServer.screen_get_size()) + ")")
	else:
		# Set to windowed mode and restore a default window size
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(800, 600))
		console.add_output("Fullscreen: [color=green]OFF[/color] (Windowed: 800x600)")
