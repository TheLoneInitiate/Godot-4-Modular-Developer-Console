extends Node

var console: Node  # Reference to DeveloperConsole

func run(args: Array) -> void:
	if not console.is_authenticated:
		console.add_output("Access denied. Please enter the correct password with 'rcon_password' first.")
		return
	if args.size() < 4:
		console.add_output("Usage: set <node_name> <property> <value> [value2] [value3]")
		return
	
	var node_name = args[1]
	var property = args[2]
	var value = args[3]
	
	var target_node = console.get_node("/root").find_child(node_name, true, false)
	if not target_node:
		console.add_output("Node '" + node_name + "' not found in the scene tree.")
		return
	
	# Handle vector properties
	if property == "scale" or property == "position" or property == "rotation_degrees":
		if target_node is Node2D and args.size() >= 5:
			var x = args[3].to_float() if args[3].is_valid_float() else null
			var y = args[4].to_float() if args[4].is_valid_float() else null
			if x != null and y != null:
				target_node.set(property, Vector2(x, y))
				console.add_output("Set " + node_name + "." + property + " to (" + str(x) + ", " + str(y) + ")")
			else:
				console.add_output("Invalid values for " + property + ": '" + args[3] + "', '" + args[4] + "' must be numbers.")
		elif target_node is Node3D and args.size() >= 6:
			var x = args[3].to_float() if args[3].is_valid_float() else null
			var y = args[4].to_float() if args[4].is_valid_float() else null
			var z = args[5].to_float() if args[5].is_valid_float() else null
			if x != null and y != null and z != null:
				target_node.set(property, Vector3(x, y, z))
				console.add_output("Set " + node_name + "." + property + " to (" + str(x) + ", " + str(y) + ", " + str(z) + ")")
			else:
				console.add_output("Invalid values for " + property + ": '" + args[3] + "', '" + args[4] + "', '" + args[5] + "' must be numbers.")
		else:
			console.add_output("For " + property + ", provide 2 values (x y) for 2D or 3 values (x y z) for 3D.")
		return
	
	# Handle exported scalar properties
	if target_node.has_method("get_property_list"):
		var properties = target_node.get_property_list()
		for prop in properties:
			if prop.name == property and prop.usage & PROPERTY_USAGE_EDITOR:
				var converted_value = convert_value(value, prop.type)
				if converted_value != null:
					target_node.set(property, converted_value)
					console.add_output("Set " + node_name + "." + property + " to " + str(converted_value))
				else:
					console.add_output("Invalid value '" + value + "' for type " + str(prop.type) + ".")
				return
		console.add_output("Variable '" + property + "' not found or not exported in " + node_name + ".")
	else:
		console.add_output("Cannot access properties of " + node_name + ".")

func convert_value(value: String, type: int) -> Variant:
	match type:
		TYPE_INT:
			return value.to_int() if value.is_valid_int() else null
		TYPE_FLOAT:
			return value.to_float() if value.is_valid_float() else null
		TYPE_BOOL:
			return true if value.to_lower() == "true" else (false if value.to_lower() == "false" else null)
		TYPE_STRING:
			return value
		_:
			return null
