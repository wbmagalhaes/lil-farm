extends Node2D

class_name RemotePlayer

@onready var animation = $AnimationPlayer

var remote_player_id: int

var player_name: String
var player_color: String

func _ready():
	NetworkManager.connect('move_command_received', self._on_move_command_received)

func initialize(player_data: Dictionary):
	animation = $AnimationPlayer

	remote_player_id = int(player_data.get("id"))
	player_name = player_data.get("name")
	player_color = player_data.get("color")

	update_position(player_data.get("position"))
	update_direction(player_data.get("direction"))
	update_animation(player_data.get("animation"))

func update_position(pos):
	if pos == null:
		return

	var x = pos.get("x")
	var y = pos.get("y")
	set_position(Vector2(x, y))

func update_direction(dir):
	if dir == null:
		return

func update_animation(anim):
	if anim == null:
		return

	animation.play(anim)

func destroy():
	queue_free()

func _on_move_command_received(player_id: int, move_data: Dictionary):
	if player_id != remote_player_id:
		return

	update_position(move_data.get("position"))
	update_direction(move_data.get("direction"))
	update_animation(move_data.get("animation"))
