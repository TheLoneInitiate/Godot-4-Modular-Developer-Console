extends Control

@onready var input: LineEdit = $Panel/Input
@onready var output: RichTextLabel = $Panel/Output
@onready var panel: Panel = $Panel


var ConsoleReady: bool
var perf_hud: Node = null  # Tracks the profiling HUD instance
var is_console_open: bool = false
var is_authenticated: bool = false
var command_history: Array[String] = []
var history_index: int = -1
const MAX_HISTORY_SIZE: int = 50

var node_list: Array[Node] = []
var subtree_list: Array[Node] = []
var awaiting_selection: bool = false
var is_subtree_mode: bool = false
var previous_mouse_mode: int = Input.MOUSE_MODE_CAPTURED

var commands: Dictionary = {}
const COMMANDS_DIR = "res://scripts/console/commands/"

# Persistence settings
const AUTO_SAVE: bool = true
const AUTO_LOAD: bool = true
const LOG_DIR = "res://logs/"
var current_log_file: String = ""

# Tab completion state
var completion_matches: Array[String] = []
var completion_index: int = -1

func _ready() -> void:
	panel.visible = false
	input.connect("text_submitted", _on_input_submitted)
	previous_mouse_mode = Input.mouse_mode
	load_commands()
	DirAccess.make_dir_recursive_absolute(LOG_DIR)
	ConsoleReady = true
	if AUTO_LOAD:
		load_most_recent_log()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_QUOTELEFT:
		toggle_console()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and is_console_open:
		if event.keycode == KEY_UP:
			navigate_history(1)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_DOWN:
			navigate_history(-1)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_TAB:
			complete_command()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and awaiting_selection:
			# Cancel awaiting selection state
			awaiting_selection = false
			is_subtree_mode = false
			add_output("Selection cancelled.")
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and is_console_open:
		var v_scroll = output.get_v_scroll_bar()
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			v_scroll.value -= 10
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			v_scroll.value += 10
			get_viewport().set_input_as_handled()

func toggle_console() -> void:
	is_console_open = !is_console_open
	panel.visible = is_console_open
	if is_console_open:
		previous_mouse_mode = Input.mouse_mode
		input.grab_focus()
		input.clear()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		input.release_focus()
		input.clear()
		awaiting_selection = false
		is_subtree_mode = false
		history_index = -1
		completion_matches.clear()
		completion_index = -1
		Input.mouse_mode = previous_mouse_mode

func _on_input_submitted(text: String) -> void:
	var trimmed_text = text.strip_edges()
	if trimmed_text != "":
		if command_history.size() >= MAX_HISTORY_SIZE:
			command_history.pop_front()
		command_history.append(trimmed_text)
		history_index = -1
		completion_matches.clear()
		completion_index = -1
	process_command(text)
	input.clear()
	if is_console_open:
		input.grab_focus()

func navigate_history(direction: int) -> void:
	if command_history.is_empty():
		return
	
	var new_index = history_index + direction
	if new_index < -1:
		new_index = -1
	elif new_index >= command_history.size():
		new_index = -1
	
	history_index = new_index
	
	if history_index == -1:
		input.text = ""
	else:
		input.text = command_history[command_history.size() - 1 - history_index]
	input.caret_column = input.text.length()

func complete_command() -> void:
	var text = input.text.strip_edges()
	if text.is_empty():
		return
	
	var parts = text.split(" ", false)
	var current_word = parts[-1] if parts.size() > 0 else ""
	var prefix = text.substr(0, text.length() - current_word.length()).strip_edges()
	
	if completion_matches.is_empty() or input.text != (prefix + " " + completion_matches[completion_index] if completion_index >= 0 else text):
		completion_matches.clear()
		completion_index = -1
		
		if parts.size() == 1:
			for cmd in commands.keys():
				if cmd.begins_with(current_word.to_lower()):
					completion_matches.append(cmd)
		elif parts.size() >= 2:
			var command = parts[0].to_lower()
			if command in ["set", "load_scene"]:
				if command == "set":
					var root = get_node("/root")
					for node in get_all_nodes(root):
						if node.name.to_lower().begins_with(current_word.to_lower()):
							completion_matches.append(node.name)
				elif command == "load_scene":
					var dir = DirAccess.open("res://scenes/")
					if dir:
						dir.list_dir_begin()
						var file_name = dir.get_next()
						while file_name != "":
							if file_name.ends_with(".tscn"):
								var scene_name = file_name.get_basename()
								if scene_name.to_lower().begins_with(current_word.to_lower()):
									completion_matches.append(scene_name)
							file_name = dir.get_next()
	
	if not completion_matches.is_empty():
		completion_index = (completion_index + 1) % completion_matches.size()
		if parts.size() == 1:
			input.text = completion_matches[completion_index]
		else:
			input.text = prefix + " " + completion_matches[completion_index]
		input.caret_column = input.text.length()
	else:
		add_output("No matches found for '" + current_word + "'")

func get_all_nodes(node: Node) -> Array[Node]:
	var nodes: Array[Node] = [node]
	for child in node.get_children():
		nodes.append_array(get_all_nodes(child))
	return nodes

func load_commands() -> void:
	var dir = DirAccess.open(COMMANDS_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".gd"):
				var command_name = file_name.get_basename()
				var script_path = COMMANDS_DIR + file_name
				var script = load(script_path)
				if script and script.can_instantiate():
					var instance = script.new()
					if instance.has_method("run"):
						commands[command_name] = instance
						instance.console = self
			file_name = dir.get_next()
	else:
		push_error("Failed to open commands directory: " + COMMANDS_DIR)

func process_command(command: String) -> void:
	var parts: Array = command.strip_edges().split(" ")
	if parts.size() == 0:
		add_output("Empty command.")
		return

	if awaiting_selection:
		if parts.size() == 1 and parts[0].is_valid_int():
			var index = parts[0].to_int()
			var current_list = subtree_list if is_subtree_mode else node_list
			if index >= 0 and index < current_list.size():
				awaiting_selection = false
				is_subtree_mode = true
				commands["rcon_tree"].print_node_subtree(current_list[index])
			else:
				add_output("Invalid index: " + str(index) + ". Must be between 0 and " + str(current_list.size() - 1) + ".")
		else:
			add_output("Please enter a single number corresponding to a node index.")
		return

	var action = parts[0].to_lower()
	if commands.has(action):
		commands[action].run(parts)
	else:
		add_output("Unknown command: " + action)

func add_output(message: String) -> void:
	var v_scroll = output.get_v_scroll_bar()
	var was_at_bottom = v_scroll.value >= v_scroll.max_value - v_scroll.page
	output.append_text(message + "\n")
	if was_at_bottom:
		output.scroll_to_line(output.get_line_count() - 1)
	if AUTO_SAVE:
		if current_log_file.is_empty():
			current_log_file = LOG_DIR + "console_" + Time.get_datetime_string_from_system().replace(":", "") + ".txt"
		save_to_log(message)

func save_to_log(message: String) -> void:
	var file = FileAccess.open(current_log_file, FileAccess.WRITE if not FileAccess.file_exists(current_log_file) else FileAccess.READ_WRITE)
	if file:
		if FileAccess.file_exists(current_log_file):
			file.seek_end()
		file.store_string(message + "\n")
		file.close()
	else:
		push_error("Failed to write to log file: " + current_log_file)

func load_most_recent_log() -> void:
	var dir = DirAccess.open(LOG_DIR)
	if dir:
		var latest_file = ""
		var latest_time = 0
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".txt"):
				var file_path = LOG_DIR + file_name
				var mod_time = FileAccess.get_modified_time(file_path)
				if mod_time > latest_time:
					latest_time = mod_time
					latest_file = file_path
			file_name = dir.get_next()
		if latest_file != "":
			current_log_file = latest_file
			var file = FileAccess.open(latest_file, FileAccess.READ)
			if file:
				output.clear()
				output.append_text("Loaded log: " + latest_file.get_file() + "\n")  # Message first
				while not file.eof_reached():
					var line = file.get_line()
					if not line.is_empty():
						output.append_text(line + "\n")
				file.close()
				output.scroll_to_line(output.get_line_count() - 1)  # Scroll to bottom
	else:
		add_output("No logs found in " + LOG_DIR)
