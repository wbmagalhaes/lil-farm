extends CanvasLayer

@onready var player: Player = $"../player"

func _unhandled_input(event):
	if event.is_action_pressed("inventory"):
		if player.inventory.visible:
			player.inventory.close()
		else:
			player.inventory.open()
