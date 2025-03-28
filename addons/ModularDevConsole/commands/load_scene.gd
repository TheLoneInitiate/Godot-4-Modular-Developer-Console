extends Node

var console: Node  # Reference to DeveloperConsole

const SCENES_DIR = "res://scenes/"  # Directory where .tscn files are stored

func run(args: Array) -> void:
	if args.size() < 2:
		# List available scenes if no argument is provided
		list_available_scenes()
		return
	
	var scene_name = args[1]  # e.g., "Main"
	var scene_path = SCENES_DIR + scene_name + ".tscn"
	
	# Check if the scene file exists
	if ResourceLoader.exists(scene_path):
		console.add_output("Loading scene: " + scene_name + "...")
		console.get_tree().change_scene_to_file(scene_path)
	else:
		console.add_output("Scene '" + scene_name + "' not found in " + SCENES_DIR)

func list_available_scenes() -> void:
	var dir = DirAccess.open(SCENES_DIR)
	if dir:
		console.add_output("Available scenes in " + SCENES_DIR + ":")
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				var scene_name = file_name.get_basename()
				console.add_output("- " + scene_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		console.add_output("Failed to open scenes directory: " + SCENES_DIR)
