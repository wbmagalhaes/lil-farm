extends Node

@onready var _env: Dictionary = load_dotenv("res://.env")

func load_dotenv(filename: String) -> Dictionary:
	if not FileAccess.file_exists(filename):
		return {};

	var file = FileAccess.open(filename, FileAccess.READ)
	var env = {}

	while not file.eof_reached():
		var line: String = file.get_line().strip_edges()

		if line.is_empty():
			continue

		if line.begins_with('#'):
			continue

		var splitted: PackedStringArray = line.split("=")
		var key = splitted[0].strip_edges().to_lower()
		var value = splitted[1].strip_edges()
		env[key] = value

	return env

func get_variable(variable_name: String, default = "") -> String:
	variable_name = variable_name.to_lower()

	if OS.has_environment(variable_name):
		return OS.get_environment(variable_name);

	if _env.has(variable_name):
		return _env[variable_name];

	return default;
