class_name MoveData

var position: Vector2
var direction: String
var animation: String

func _init(json_data: Dictionary):
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
