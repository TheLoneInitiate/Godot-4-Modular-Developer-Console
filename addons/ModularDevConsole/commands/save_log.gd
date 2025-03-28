extends Node

var console: Node  # Reference to DeveloperConsole

func run(args: Array) -> void:
	var file_name = "console_" + Time.get_datetime_string_from_system().replace(":", "") + ".txt"
	if args.size() > 1:
		file_name = args[1] + ".txt"  # Allow custom name (e.g., save_log mylog)
	
	console.current_log_file = console.LOG_DIR + file_name
	var file = FileAccess.open(console.current_log_file, FileAccess.WRITE)
	if file:
		file.store_string(console.output.text)
		file.close()
		console.add_output("Saved log to: " + console.current_log_file)
	else:
		console.add_output("Failed to save log to: " + console.current_log_file)
