class_name ItemPickup
extends Area2D

@export var item_data: ItemData

func _ready():
	var instance = item_data.scene.instantiate()
	add_child(instance)

func on_picked():
	queue_free()
