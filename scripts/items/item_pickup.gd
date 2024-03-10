class_name ItemPickup
extends Area2D

@onready var collision_shape = $CollisionShape2D

func get_item() -> Item:
	return get_parent() as Item

func set_disabled(disabled: bool):
	collision_shape.set_deferred('disabled', disabled)
