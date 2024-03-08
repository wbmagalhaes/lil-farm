extends CanvasLayer

@onready var player: Player = $"../player"
@onready var inventory_dialog: InventoryDialog = $inventory_dialog

func _unhandled_input(event):
	if event.is_action_pressed("inventory"):
		inventory_dialog.open(player.inventory)
