class_name PlayerData

var id: int
var name: String
var color: String
var position: Vector2
var direction: String
var animation: String

func _init(json_data: Dictionary):
	id = int(json_data.get("id"))
	name = json_data.get("name")
	color = json_data.get("color")

	var pos = json_data.get("position")
	if pos != null:
		var pos_x = pos.get("x")
		var pos_y = pos.get("y")
		position = Vector2(pos_x, pos_y)

	var dir = json_data.get("direction")
	if dir != null:
		direction = dir

	var anim = json_data.get("animation")
	if anim != null:
		animation = anim
