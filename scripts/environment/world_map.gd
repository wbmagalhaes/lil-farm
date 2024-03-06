class_name WorldMap
extends Node2D

signal farm_area_hover_start(farm_area: FarmArea)
signal farm_area_hover_end(farm_area: FarmArea)

func start_hover_farm_area(farm_area: FarmArea):
	farm_area_hover_start.emit(farm_area)

func end_hover_farm_area(farm_area: FarmArea):
	farm_area_hover_end.emit(farm_area)
