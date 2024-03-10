class_name ItemSlot
extends Control

signal slot_mouse_entered(slot: ItemSlot)
signal slot_mouse_exited(slot: ItemSlot)

@onready var filter: ColorRect = $Border/Status

var index: int
var hovering: bool = false
var state: State = State.DEFAULT
var item_stored: ItemView = null

enum State {
	DEFAULT,
	TAKEN,
	FREE,
}

func _ready():
	set_color(State.DEFAULT)

func set_color(_state: State):
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
		slot_mouse_entered.emit(self)
	elif hovering and not mouse_inside:
		hovering = false
		slot_mouse_exited.emit(self)
