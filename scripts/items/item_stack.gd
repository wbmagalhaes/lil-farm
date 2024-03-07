class_name ItemStack

var count: int = 1

var inventory: Inventory
var index_in_inventory: int = 1
var position_in_inventory: Vector2 = Vector2.ZERO

var item_data: ItemData

func _init(item_data: ItemData, item_count: int = 1, item_extra_properties = null):
	self.item_data = item_data
	self.count = item_count

func duplicate_with_count(new_count: int):
	var new_stack = ItemStack.new(
		item_data,
		new_count,
	)

	return new_stack

func set_count_and_update(new_count: int):
	inventory.add_items_to_stack(self, new_count - count)

func get_overflow_if_added(count_delta: int) -> int:
	return int(max(count + count_delta - item_data.max_stack_count, 0))

func get_delta_if_added(count_delta: int) -> int:
	return int(min(item_data.max_stack_count - count, count_delta))

func can_stack_with(other: ItemStack, compare_extras: bool = true) -> bool:
	return item_data == other.item_data

func matches(other : ItemStack):
	return can_stack_with(other)
	
func get_name() -> String:
	return item_data.name
	
func emit_changed():
	if inventory == null: return

	if count <= 0:
		inventory.item_stack_removed.emit(self)
	else:
		inventory.item_stack_changed.emit(self, 0)
		
static func get_stack_overflow_if_added(count: int, added: int, maxcount: int) -> int:
	return int(max(count + added - maxcount, 0))

static func get_stack_delta_if_added(count: int, added: int, maxcount: int) -> int:
	return int(min(maxcount - count, added))

static func from_dict(dict: Dictionary) -> ItemStack:
	var new_item = ItemStack.new(
		load(dict[&"type"]),
		dict[&"count"],
	)

	var new_position = dict.get(&"position", Vector2(-1, -1))
	if new_position is Vector3:
		new_position = Vector2(-1, -1)

	new_item.position_in_inventory = new_position
	return new_item

func to_dict():
	return {
		&"type" : item_data.resource_path,
		&"position" : position_in_inventory,
		&"count" : count,
	}
