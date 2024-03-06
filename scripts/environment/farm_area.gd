class_name FarmArea
extends Area2D

@onready var world_map: WorldMap = $".."
@onready var farm_tilemap: TileMap = %farm

const GROUND_LAYER: int = 0
const WATER_LAYER: int = 1
const PLANTS_LAYER: int = 2

const TILLED_SOIL_SOURCE_ID: int = 0
const TILLED_SOIL_TILE_COORD: Vector2i = Vector2i(3, 4)

const IS_FARMABLE_DATALAYER: String = 'farmable'

func _ready() -> void:
	self.mouse_entered.connect(self._on_mouse_entered)
	self.mouse_exited.connect(self._on_mouse_exited)

func _on_mouse_entered():
	world_map.start_hover_farm_area(self)

func _on_mouse_exited():
	world_map.end_hover_farm_area(self)

func get_hovered_tile_coord() -> Vector2i:
	var mouse_pos = get_global_mouse_position()
	return farm_tilemap.local_to_map(to_local(mouse_pos))

func tile_is_farmable(coord: Vector2i) -> bool:
	var tile_data = farm_tilemap.get_cell_tile_data(
		GROUND_LAYER,
		coord,
	)

	return tile_data.get_custom_data(IS_FARMABLE_DATALAYER) if tile_data else false

func till_soil(tile_coord: Vector2i) -> void:
	farm_tilemap.set_cell(
		PLANTS_LAYER,
		tile_coord,
		TILLED_SOIL_SOURCE_ID,
		TILLED_SOIL_TILE_COORD,
	)
