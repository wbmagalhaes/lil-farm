class_name RemotePlayer
extends Node2D

@export var animation: AnimationPlayer

var data: PlayerData

func initialize(player_data: PlayerData):
	data = player_data

	update_position(player_data.position)
	update_direction(player_data.direction)
	update_animation(player_data.animation)

func update_position(pos: Vector2):
	if not pos:
		return

	# TODO: lerp position
	set_position(pos)

func update_direction(dir: String):
	if not dir:
		return

	pass

func update_animation(anim: String):
	if not anim:
		return

	animation.play(anim)

func destroy():
	queue_free()
