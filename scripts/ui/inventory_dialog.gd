class_name Inventory
extends Control

@export var capacity: int = 48
@export var slot_scene: PackedScene
@export var item_view_scene: PackedScene

@onready var grid_container = $ColorRect/MarginContainer/VBoxContainer/Content

var col_count = 6
var _slots: Array[ItemSlot] = []

var slot_hovered: ItemSlot = null
var item_grabbed: ItemView = null
var icon_anchor : Vector2
var can_place = false

func _ready():
	spawn_slots()
	hide()
	
func _process(_delta):
	if item_grabbed:
		if Input.is_action_just_pressed("right_click"):
			on_rotate_clicked()

		if Input.is_action_just_pressed("left_click"):
			on_place_clicked()

	else:
		if Input.is_action_just_pressed("left_click"):
			on_pick_clicked()
			

func add_item(item: Item) -> bool:
	print('picked the item: ', item.data.name)
	
	# TODO: check for item rotations
	var available = get_available_slot(item)
	if available == null:
		return false
	
	var new_item_view: ItemView = item_view_scene.instantiate()
	new_item_view.setup(item)
	self.add_child(new_item_view)

	place_item(available, new_item_view)

	clear_slots()
	if slot_hovered:
		_on_slot_mouse_entered(slot_hovered)

	return true

func remove_item(_item: Item):
	pass

func open():
	show()

func close():
	hide()

func _on_close_button_pressed():
	close()

func _on_slot_mouse_entered(slot: ItemSlot):
	slot_hovered = slot

	if item_grabbed:
		can_place = check_slot_availability(slot, item_grabbed.get_grid())
		mark_slots_availability.call_deferred(slot, can_place)

func _on_slot_mouse_exited(_slot: ItemSlot):
	clear_slots()
	
	var grid_rect = grid_container.get_global_rect()
	var mouse_pos = get_global_mouse_position()
	if not grid_rect.has_point(mouse_pos):
		slot_hovered = null

func on_pick_clicked():
	if slot_hovered != null and slot_hovered.item_stored:
		pick_item(slot_hovered)

		can_place = check_slot_availability(slot_hovered, item_grabbed.get_grid())
		mark_slots_availability.call_deferred(slot_hovered, can_place)

func on_place_clicked():
	if slot_hovered != null and can_place:
		place_item(slot_hovered, item_grabbed)
		item_grabbed = null
		clear_slots()

func on_rotate_clicked():
	if item_grabbed != null:
		rotate_item(item_grabbed)

		clear_slots()
		if slot_hovered:
			_on_slot_mouse_entered(slot_hovered)

func get_available_slot(item: Item) -> ItemSlot:
	for slot in _slots:
		if check_slot_availability(slot, item.data.grid):
			return slot

	return null

func check_slot_availability(slot: ItemSlot, grid: Array[Vector2i]) -> bool:
	for cell in grid:
		var slot_to_check = slot.index + cell.x + cell.y * col_count
		var line_to_check = slot.index % col_count + cell.x

		if line_to_check < 0 or line_to_check >= col_count:
			return false

		if slot_to_check < 0 or slot_to_check >= _slots.size():
			return false

		if _slots[slot_to_check].state == ItemSlot.State.TAKEN:
			return false

	return true

func mark_slots_availability(slot: ItemSlot, available: bool):
	for cell in item_grabbed.get_grid():
		var slot_to_check = slot.index + cell.x + cell.y * col_count
		var line_to_check = slot.index % col_count + cell.x

		if line_to_check < 0 or line_to_check >= col_count:
			continue
		if slot_to_check < 0 or slot_to_check >= _slots.size():
			continue

		if available:
			_slots[slot_to_check].set_color(ItemSlot.State.FREE)
			if cell.x < icon_anchor.x: icon_anchor.x = cell.x
			if cell.y < icon_anchor.y: icon_anchor.y = cell.y
		else:
			_slots[slot_to_check].set_color(ItemSlot.State.TAKEN)

func clear_slots():
	for slot in _slots:
		slot.set_color(ItemSlot.State.DEFAULT)

func rotate_item(item: ItemView):
	item.rotate_item()

func place_item(slot: ItemSlot, item: ItemView):
	if not slot:
		 # put indication of placement failed, sound or visual here
		return

	# item.get_parent().remove_child(item)
	# grid_container.add_child(item)
	# item.global_position = get_global_mouse_position()

	var snap_slot_index = slot.index + icon_anchor.x * col_count + icon_anchor.y
	var target_position = _slots[snap_slot_index].global_position

	item.on_place(slot, target_position)
	for cell in item.get_grid():
		var slot_to_check = slot.index + cell.x + cell.y * col_count
		_slots[slot_to_check].state = ItemSlot.State.TAKEN 
		_slots[slot_to_check].item_stored = item

func pick_item(slot: ItemSlot):
	if not slot or not slot.item_stored: 
		return

	slot.item_stored.grab()
	item_grabbed = slot.item_stored

	# item_grabbed.get_parent().remove_child(item_grabbed)
	# add_child(item_grabbed)
	# item_grabbed.global_position = get_global_mouse_position()

	for cell in item_grabbed.get_grid():
		var anchor = item_grabbed.get_anchor()
		var slot_to_check = anchor.index + cell.x + cell.y * col_count
		_slots[slot_to_check].state = ItemSlot.State.FREE 
		_slots[slot_to_check].item_stored = null

func spawn_slots():
	for i in range(capacity):
		var new_slot: ItemSlot = slot_scene.instantiate()
		new_slot.index = i
		grid_container.add_child(new_slot)
		_slots.append(new_slot)

		new_slot.slot_mouse_entered.connect(self._on_slot_mouse_entered)
		new_slot.slot_mouse_exited.connect(self._on_slot_mouse_exited)

static func from_dict(_dict: Dictionary):
	pass

func to_dict():
	pass
