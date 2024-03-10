class_name ItemSlot
extends Control

signal slot_mouse_entered(slot: ItemSlot)
signal slot_mouse_exited(slot: ItemSlot)

@onready var filter: ColorRect = $Border/Status

var index: int
var _hovering: bool = false
var _state: State = State.DEFAULT
var _item_stored: ItemView = null

enum State {
	DEFAULT,
	TAKEN,
	FREE,
}

func _ready():
	set_color(State.DEFAULT)

func set_color(state: State):
	match state:
		State.DEFAULT:
			filter.color = Color(Color.WHITE, 0.2)
		State.TAKEN:
			filter.color = Color(Color.RED, 0.2)
		State.FREE:
			filter.color = Color(Color.GREEN, 0.2)

func add_item(item: ItemView):
	_item_stored = item
	_state = ItemSlot.State.TAKEN

func get_item() -> ItemView:
	return _item_stored

func remove_item():
	_item_stored = null
	_state = ItemSlot.State.FREE

func is_taken() -> bool:
	return _state == ItemSlot.State.TAKEN

func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	var mouse_inside = get_global_rect().has_point(mouse_pos)

	if mouse_inside and not _hovering:
		_hovering = true
		slot_mouse_entered.emit(self)
	elif _hovering and not mouse_inside:
		_hovering = false
		slot_mouse_exited.emit(self)
