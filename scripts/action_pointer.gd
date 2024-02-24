extends Node2D

var TILE_SIZE: int = 16;
var ACTION_INPUT: String = "click"
var VALID_COLOR: Color = Color('#88e361')
var INVALID_COLOR: Color = Color('#da7c41')

@onready var world_map: WorldMap = $"../world_map"
# @onready var player: LocalPlayer = $"../player"

@onready var animation_player = $AnimationPlayer

var current_hovered_farm_area: FarmArea
var current_holded_item: String

func _ready():
	animation_player.play("boop")

	world_map.farm_area_hover_start.connect(self._on_farm_area_hover_start)
	world_map.farm_area_hover_end.connect(self._on_farm_area_hover_end)

	# TODO: get holded item
	# player.holded_item_changed.connect(self._on_holded_item_changed)

func get_mouse_coord() -> Vector2i:
	var mouse_pos = get_global_mouse_position()
	var x= int((floori(mouse_pos.x / TILE_SIZE) + 0.5) * TILE_SIZE)
	var y= int((floori(mouse_pos.y / TILE_SIZE) + 0.5) * TILE_SIZE)
	return Vector2i(x, y)

func has_valid_action() -> bool:
	if not current_hovered_farm_area:
		return false

	var tile_coord = current_hovered_farm_area.get_hovered_tile_coord()
	var hovering_farmable = current_hovered_farm_area.tile_is_farmable(tile_coord)
	if not hovering_farmable:
		return false

	# TODO: check for farm actions depending on the selected item
	# hoe -> till
	# seeds -> plant
	# watering can -> water
	# nothing -> harvest
	return true

func move_pointer():
	var mouse_coord = get_mouse_coord()
	global_position = mouse_coord

func validate_action():
	var valid_action = has_valid_action()
	modulate = Color.GREEN if valid_action else INVALID_COLOR
	return valid_action

func perform_action():
	# send action to server
	pass

func _process(_delta):
	move_pointer()

	var valid_action = validate_action()

	if Input.is_action_just_pressed(ACTION_INPUT):
		if valid_action:
			perform_action()
		else:
			# invalid feedback
			pass

func _on_holded_item_changed(item: String):
	current_holded_item = item

func _on_farm_area_hover_start(area: FarmArea):
	current_hovered_farm_area = area

func _on_farm_area_hover_end(_area: FarmArea):
	current_hovered_farm_area = null
