class_name ItemSlot
extends Control

signal slot_entered(slot: ItemSlot)
signal slot_exited(slot: ItemSlot)

@onready var filter: ColorRect = $Border/Status

var slot_id: int
var hovering: bool = false
var state: State = State.DEFAULT
var item_stored: Item = null

enum State {
	DEFAULT,
	TAKEN,
	FREE,
}

func set_color(_state: State):
	state = _state

	match _state:
		State.DEFAULT:
			filter.color = Color(Color.WHITE, 0.2)
		State.TAKEN:
			filter.color = Color(Color.RED, 0.2)
		State.FREE:
			filter.color = Color(Color.GREEN, 0.2)

func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	var mouse_inside = get_global_rect().has_point(mouse_pos)

	if mouse_inside and not hovering:
		hovering = true
		slot_entered.emit(self)
	elif hovering and not mouse_inside:
		hovering = false
		slot_exited.emit(self)
