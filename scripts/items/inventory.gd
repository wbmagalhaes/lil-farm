class_name Inventory

var _size: int
var _content: Array[Item] = []

signal loaded_from_dict(dict: Dictionary)

func _init(size: int):
	_size = size
	_content.resize(size)
	_content.fill(null)

func add_item(item: Item):
	_content.append(item)

func remove_item(item: Item):
	_content.erase(item)

func get_items() -> Array[Item]:
	return _content

static func from_dict(_dict: Dictionary):
	pass

func to_dict():
	pass
