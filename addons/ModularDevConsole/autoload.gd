@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton("ModularDevConsole", "res://addons/ModularDevConsole/console.tscn")

func _exit_tree() -> void:
	remove_autoload_singleton("ModularDevConsole")
