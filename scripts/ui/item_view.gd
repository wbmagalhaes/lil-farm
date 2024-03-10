class_name ItemView
extends Node2D

@export var _sprite_2d: Sprite2D

var _item: Item = null
var _selected = false
var _size: Vector2

var _grid: Array[Vector2i]
var _grid_anchor: ItemSlot

func setup(item: Item):
	_item = item
	_selected = false

	_grid = []
	for cell in item.data.grid:
		_grid.append(Vector2i(cell.x, cell.y))

	_sprite_2d.set_texture(item.data.icon)
	_size = _sprite_2d.get_rect().size

func _process(delta):
	if _selected:
		var mouse_pos = get_global_mouse_position()
		global_position = lerp(global_position, mouse_pos, 25 * delta)

func grab():
	_selected = true
	z_index = 100

	var tween = get_tree().create_tween()
	tween.tween_property(_sprite_2d, "scale", Vector2(1.1, 1.1), 0.15).set_trans(Tween.TRANS_SPRING)

func on_place(anchor: ItemSlot, target: Vector2):
	_snap_to(target)

	_selected = false
	_grid_anchor = anchor
	z_index = 0

	var tween = get_tree().create_tween()
	tween.tween_property(_sprite_2d, "scale", Vector2(1, 1), 0.15).set_trans(Tween.TRANS_SPRING)

func rotate_item():
	var new_grid: Array[Vector2i] = []
	for cell in _grid:
		new_grid.append(Vector2i(-cell.y, cell.x))
	_grid = new_grid

	rotation_degrees += 90

	if rotation_degrees >= 360:
		rotation_degrees = 0

func _snap_to(target: Vector2):
	print(target)
	print(rotation_degrees)
	print(_size)

	if int(rotation_degrees) % 180 == 0:
		target += _size / 2
	else:
		target += Vector2(_size.y, _size.x) / 2

	global_position = target
	# var tween = get_tree().create_tween()
	# tween.tween_property(self, "global_position", target, 0.15).set_trans(Tween.TRANS_SINE)

func get_grid() -> Array[Vector2i]:
	return _grid

func get_anchor() -> ItemSlot:
	return _grid_anchor
