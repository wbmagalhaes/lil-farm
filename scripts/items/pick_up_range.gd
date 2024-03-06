class_name PickupRange
extends Area2D

signal pick_item(item_pickup: ItemPickup)

func _ready():
	self.area_entered.connect(self._on_area_entered)
	self.area_exited.connect(self._on_area_exited)

func _on_area_entered(area: Area2D):
	var pickup = area as ItemPickup
	if pickup == null:
		return

	pick_item.emit(pickup)

func _on_area_exited(area: Area2D):
	var pickup = area as ItemPickup
	if pickup == null:
		return
