extends Node

var console: Node  # Reference to DeveloperConsole

func run(args: Array) -> void:
	if args.size() < 2:
		console.load_most_recent_log()  # Default to most recent if no arg
		return
	
	var file_name = console.LOG_DIR + args[1] + ".txt"
	if FileAccess.file_exists(file_name):
		var file = FileAccess.open(file_name, FileAccess.READ)
		if file:
			console.output.clear()
			console.output.append_text("Loaded log: " + file_name.get_file() + "\n")  # Message first
			while not file.eof_reached():
				var line = file.get_line()
				if not line.is_empty():
					console.output.append_text(line + "\n")
			file.close()
			console.current_log_file = file_name
			console.output.scroll_to_line(console.output.get_line_count() - 1)  # Scroll to bottom
	else:
		console.add_output("Log file not found: " + file_name)
