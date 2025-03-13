extends Control

@onready var stats_label = $StatsLabel

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	var process_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000  # ms
	var physics_time = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000  # ms
	
	var text = "[b]Performance Stats:[/b]\n"
	text += "[color=green]FPS:[/color] " + str(fps) + "\n"
	text += "[color=green]Process Time:[/color] " + str(snapped(process_time, 0.1)) + " ms\n"
	text += "[color=green]Physics Time:[/color] " + str(snapped(physics_time, 0.1)) + " ms"
	
	stats_label.text = text
