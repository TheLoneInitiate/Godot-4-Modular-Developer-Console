extends Node

var console: Node  # Reference to DeveloperConsole

func run(args: Array) -> void:
	if console.perf_hud:
		# Turn off performance HUD
		console.perfe_hud.queue_free()
		console.perf_hud = null
		console.add_output("Performance HUD disabled.")
	else:
		# Turn on performance HUD
		console.perf_hud = preload("res://scenes/perf_hud.tscn").instantiate()
		console.get_node("/root").add_child(console.perf_hud)
		console.perf_hud.owner = console.get_node("/root")
		console.add_output("Performance HUD enabled. Stats displayed on screen.")
