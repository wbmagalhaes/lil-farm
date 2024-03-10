class_name ItemView
extends Node2D

@export var _sprite_2d: Sprite2D

var _item: Item = null
var _selected = false
var _size: Vector2

var _grid: Array[Vector2i]
var _grid_anchor: ItemSlot

const FOLLOW_MOUSE_SPEED = 25
const TRANSITION_DURATION = 0.15
const PICKED_SCALE = Vector2(1.2, 1.2)
const PICKED_Z_INDEX = 100

const HALF_PI_DEG = 90
const PI_DEG = 180
const TWO_PI_DEG = 360

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
		global_position = lerp(global_position, mouse_pos, FOLLOW_MOUSE_SPEED * delta)

func grab() -> ItemView:
	_selected = true
	z_index = PICKED_Z_INDEX

	var tween = get_tree().create_tween()
	tween.tween_property(
		self,
		"scale",
		PICKED_SCALE,
		TRANSITION_DURATION,
	).set_trans(Tween.TRANS_SPRING)
	return self

func on_place(anchor: ItemSlot, target: Vector2):
	_snap_to(target)

	_selected = false
	_grid_anchor = anchor
	z_index = 0

	var tween = get_tree().create_tween()
	tween.tween_property(
		self,
		"scale",
		Vector2.ONE,
		TRANSITION_DURATION,
	).set_trans(Tween.TRANS_SPRING)

func rotate_item():
	var new_grid: Array[Vector2i] = []
	for cell in _grid:
		new_grid.append(Vector2i(-cell.y, cell.x))
	_grid = new_grid

	rotation_degrees += HALF_PI_DEG

	if rotation_degrees >= TWO_PI_DEG:
		rotation_degrees = 0

func _snap_to(target: Vector2):
	if int(rotation_degrees) % PI_DEG == 0:
		target += _size * 0.5
	else:
		target += Vector2(_size.y, _size.x) * 0.5

	var tween = get_tree().create_tween()
	tween.tween_property(
		self,
		"global_position",
		target,
		TRANSITION_DURATION,
	).set_trans(Tween.TRANS_SINE)

func get_grid() -> Array[Vector2i]:
	return _grid

func get_anchor() -> ItemSlot:
	return _grid_anchor
