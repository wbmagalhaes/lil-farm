class_name Inventory

var _content: Array[ItemData] = []

func add_item(item: ItemData):
	_content.append(item)

func remove_item(item: ItemData):
	_content.erase(item)

func get_items() -> Array[ItemData]:
	return _content
