class_name InventoryDialog
extends PanelContainer

@export var base_slot: PackedScene
@onready var grid_container = %GridContainer

func open(inventory: Inventory):
	show()

	for child in grid_container.get_children():
		child.queue_free()

	for item in inventory.get_items():
		var slot = base_slot.instantiate()
		grid_container.add_child(slot)

func _on_close_button_pressed():
	hide()
