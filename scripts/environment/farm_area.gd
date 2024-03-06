class_name FarmArea
extends Area2D

@onready var world_map: WorldMap = $".."
@onready var farm_tilemap: TileMap = %farm

const ground_layer: int = 0
const water_layer: int = 1
const plants_layer: int = 2

const tilled_soil_source_id: int = 0
const tilled_soil_tile_coord: Vector2i = Vector2i(3, 4)

const is_farmable_datalayer: String = 'farmable'

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
		ground_layer,
		coord,
	)

	return tile_data.get_custom_data(is_farmable_datalayer) if tile_data else false

func till_soil(tile_coord: Vector2i) -> void:
	farm_tilemap.set_cell(
		plants_layer,
		tile_coord,
		tilled_soil_source_id,
		tilled_soil_tile_coord,
	)
