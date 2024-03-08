class_name InventoryDialog
extends Control

@export var slot_scene: PackedScene
@onready var grid_container = $ColorRect/MarginContainer/VBoxContainer/Content

var slots: Array[ItemSlot] = []

func _ready():
	for i in range(64):
		create_slot(i)

func create_slot(id: int):
	var new_slot: ItemSlot = slot_scene.instantiate()
	grid_container.add_child(new_slot)
	new_slot.slot_id = id
	slots.append(new_slot)
	new_slot.slot_entered.connect(self._on_slot_entered)
	new_slot.slot_exited.connect(self._on_slot_exited)

func open(_inventory: Inventory):
	show()

func _on_close_button_pressed():
	hide()

func _on_slot_entered(slot: ItemSlot):
	slot.set_color(ItemSlot.State.TAKEN)

func _on_slot_exited(slot: ItemSlot):
	slot.set_color(ItemSlot.State.DEFAULT)
