class_name Inventory

var _size: int
var _content: Array[ItemData] = []

signal item_stack_added(item_stack: ItemStack)
signal item_stack_changed(item_stack: ItemStack, count_delta: int)
signal item_stack_removed(item_stack: ItemStack)
signal loaded_from_dict(dict: Dictionary)

func _init(size: int):
	_size = size
	_content.resize(size)
	_content.fill(null)

func add_item(item: ItemData):
	_content.append(item)

func remove_item(item: ItemData):
	_content.erase(item)

func get_items() -> Array[ItemData]:
	return _content
