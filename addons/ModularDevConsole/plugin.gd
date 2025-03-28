@tool
extends EditorPlugin

var console_scene: PackedScene = preload("res://addons/ModularDevConsole/console.tscn")
var console_instance: CanvasLayer = null

func _enter_tree() -> void:
	# Register a singleton to handle runtime instantiation
	Engine.register_singleton("ModularDevConsoleLoader", self)
	get_tree().process_frame.connect(_check_runtime)

func _exit_tree() -> void:
	if console_instance:
		console_instance.queue_free()
		console_instance = null
	Engine.unregister_singleton("ModularDevConsoleLoader")
	if get_tree().process_frame.is_connected(_check_runtime):
		get_tree().process_frame.disconnect(_check_runtime)

func _check_runtime() -> void:
	if not Engine.is_editor_hint() and console_instance == null:
		print("Game running, instantiating console...")
		console_instance = console_scene.instantiate() as CanvasLayer
		if console_instance:
			get_tree().root.add_child(console_instance)
			console_instance.owner = get_tree().root
			console_instance.layer = 100
			print("Console added to scene tree: ", console_instance.get_parent())
		else:
			printerr("Failed to instantiate console.tscn")
