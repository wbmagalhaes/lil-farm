class_name ItemSlot
extends PanelContainer

func display(item: ItemData):
	var item_scene = item.scene.instantiate()
	add_child(item_scene)
