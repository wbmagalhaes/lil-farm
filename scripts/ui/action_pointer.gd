extends Node2D

const TILE_SIZE: int = 16;
const ACTION_INPUT: String = "click"

@onready var world_map: WorldMap = $"../world_map"
@onready var local_player: Player = $"../player"

@onready var animation_player: AnimationPlayer = %AnimationPlayer

@export var valid_color: Color = Color('#88e361')
@export var invalid_color: Color = Color('#da7c41')

var current_hovered_farm_area: FarmArea
var current_holded_item: String

func _ready():
	animation_player.play("boop")

	world_map.farm_area_hover_start.connect(self._on_farm_area_hover_start)
	world_map.farm_area_hover_end.connect(self._on_farm_area_hover_end)

	print(local_player)

	# TODO: get holded item
	# player.holded_item_changed.connect(self._on_holded_item_changed)

func get_mouse_coord() -> Vector2i:
	var mouse_pos = get_global_mouse_position()
	var x= int((floori(mouse_pos.x / TILE_SIZE) + 0.5) * TILE_SIZE)
	var y= int((floori(mouse_pos.y / TILE_SIZE) + 0.5) * TILE_SIZE)
	return Vector2i(x, y)

func has_valid_action(coord: Vector2i) -> bool:
	var hovering_farmable = current_hovered_farm_area.tile_is_farmable(coord)
	if not hovering_farmable:
		return false

	# TODO: check for farm actions depending on the selected item
	# hoe -> till
	# seeds -> plant
	# watering can -> water
	# nothing -> harvest
	return true

func get_farm_coord():
	if not current_hovered_farm_area:
		return null

	return current_hovered_farm_area.get_hovered_tile_coord()

func validate_action(tile_coord) -> bool:
	if tile_coord == null:
		return false

	return has_valid_action(tile_coord)

func handle_click(coord: Vector2i):
	print(coord)

func update_pointer_color(valid_action: bool):
	modulate = valid_color if valid_action else invalid_color

func update_pointer_position():
	var mouse_coord = get_mouse_coord()
	global_position = mouse_coord

func _process(_delta):
	update_pointer_position()

	var farm_coord = get_farm_coord()
	var valid_action = validate_action(farm_coord)
	update_pointer_color(valid_action)

	if Input.is_action_just_pressed(ACTION_INPUT):
		if valid_action:
			handle_click(farm_coord)
		else:
			# invalid feedback
			pass

func _on_holded_item_changed(item: String):
	current_holded_item = item

func _on_farm_area_hover_start(area: FarmArea):
	current_hovered_farm_area = area

func _on_farm_area_hover_end(_area: FarmArea):
	current_hovered_farm_area = null
