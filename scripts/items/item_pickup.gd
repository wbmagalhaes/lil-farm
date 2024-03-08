class_name ItemPickup
extends Area2D

func get_item() -> Item:
	return get_parent() as Item

func on_picked():
	queue_free()
