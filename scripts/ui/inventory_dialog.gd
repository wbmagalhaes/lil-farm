class_name InventoryDialog
extends PanelContainer

@export var base_slot: PackedScene
@onready var grid_container = %GridContainer

func open(inventory: Inventory):
	show()

func _on_close_button_pressed():
	hide()
