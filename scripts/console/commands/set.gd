extends Node

var console: Node  # Reference to DeveloperConsole

func run(args: Array) -> void:
	if not console.is_authenticated:
		console.add_output("Access denied. Please enter the correct password with 'rcon_password' first.")
		return
	if args.size() < 4:
		console.add_output("Usage: set <node> <variable> <value>")
		return
	var node_name = args[1]
	var var_name = args[2]
	var value = args[3]
	
	var target_node = console.get_node("/root").find_child(node_name, true, false)
	if not target_node:
		console.add_output("Node '" + node_name + "' not found in the scene tree.")
		return

	if target_node.has_method("get_property_list"):
		var properties = target_node.get_property_list()
		for prop in properties:
			if prop.name == var_name and prop.usage & PROPERTY_USAGE_EDITOR:
				var converted_value = convert_value(value, prop.type)
				if converted_value != null:
					target_node.set(var_name, converted_value)
					console.add_output("Set " + node_name + "." + var_name + " to " + str(converted_value))
				else:
					console.add_output("Invalid value '" + value + "' for type.")
				return
		console.add_output("Variable '" + var_name + "' not found or not exported in " + node_name + ".")
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
