extends CanvasLayer

@onready var player: Player = $"../player"

func _unhandled_input(event):
	if event.is_action_pressed("inventory"):
		player.inventory.open()
