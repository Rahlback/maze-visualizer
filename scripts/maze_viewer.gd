extends Node2D
class_name MazeView

@onready var base_layer: TileMapLayer = $BaseLayer
@onready var west_wall_layer: TileMapLayer = $WestWallLayer
@onready var east_wall_layer: TileMapLayer = $EastWallLayer
@onready var north_wall_layer: TileMapLayer = $NorthWallLayer
@onready var south_wall_layer: TileMapLayer = $SouthWallLayer
@onready var bottom_left_layer: TileMapLayer = $BottomLeftLayer
@onready var bottom_right_layer: TileMapLayer = $BottomRightLayer
@onready var top_right_layer: TileMapLayer = $TopRightLayer
@onready var top_left_layer: TileMapLayer = $TopLeftLayer

signal hovering_tile(coord: Vector2i)

const BASE_TILE = Vector2i(1, 0)
const DOWN_TILE = Vector2i(6, 0)
const LEFT_TILE = Vector2i(12, 0)
const RIGHT_TILE = Vector2i(7, 0)
const UP_TILE = Vector2i(9, 0)

const OUTER_CORNER = Vector2i(8, 0)
const INNER_CORNER = Vector2i(11, 0)

const rotate_180 = TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V
const rotate_90 = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H
const rotate_270 = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V

func set_bottom_left(coord, inner: bool) -> void:
	if inner:
		bottom_left_layer.set_cell(coord, 0, INNER_CORNER, rotate_180)
	else:
		bottom_left_layer.set_cell(coord, 0, OUTER_CORNER)

func set_bottom_right(coord, inner: bool) -> void:
	if inner:
		bottom_right_layer.set_cell(coord, 0, INNER_CORNER, rotate_90)
	else:
		bottom_right_layer.set_cell(coord, 0, OUTER_CORNER, rotate_270)

func set_top_right(coord, inner: bool) -> void:
	if inner:
		top_right_layer.set_cell(coord, 0, INNER_CORNER)
	else:
		top_right_layer.set_cell(coord, 0, OUTER_CORNER, rotate_180)

func set_top_left(coord, inner: bool) -> void:
	if inner:
		top_left_layer.set_cell(coord, 0, INNER_CORNER, rotate_270)
	else:
		top_left_layer.set_cell(coord, 0, OUTER_CORNER, rotate_90)

func set_west_wall(coord) -> void:
	west_wall_layer.set_cell(coord, 0, LEFT_TILE)

func set_east_wall(coord) -> void:
	east_wall_layer.set_cell(coord, 0, RIGHT_TILE)

func set_north_wall(coord) -> void:
	north_wall_layer.set_cell(coord, 0, UP_TILE)
	
func set_south_wall(coord) -> void:
	south_wall_layer.set_cell(coord, 0, DOWN_TILE)

func set_base_tile(coord) -> void:
	base_layer.set_cell(coord, 0, BASE_TILE)
	

const NO_TILE = Vector2i(-1, -1)

func empty_tile(layer: TileMapLayer, coord: Vector2i) -> bool:
	return layer.get_cell_atlas_coords(coord) == NO_TILE

func check_if_bottom_left_needed(coord) -> void:
	var left = coord + Vector2i(-1, 0)
	var down = coord + Vector2i(0, 1)
	
	var west_wall := not empty_tile(west_wall_layer, coord)
	var south_wall := not empty_tile(south_wall_layer, coord)
	
	if west_wall and south_wall:
		set_bottom_left(coord, true)
	elif west_wall or south_wall:
		return
	elif not empty_tile(south_wall_layer, left) or not empty_tile(west_wall_layer, down):
		set_bottom_left(coord, false)
	
	

func check_if_bottom_right_needed(coord) -> void:
	if coord == Vector2i(3, 2):
		pass

	var right = coord + Vector2i(1, 0)
	var down = coord + Vector2i(0, 1)
	
	var east_wall := not empty_tile(east_wall_layer, coord)
	var south_wall := not empty_tile(south_wall_layer, coord)
	
	var neighbor_south_wall := not empty_tile(south_wall_layer, right)
	var neighbor_east_wall := not empty_tile(east_wall_layer, down)
	 
	if east_wall and south_wall:
		set_bottom_right(coord, true)
	elif east_wall or south_wall:
		return
	elif neighbor_east_wall or neighbor_south_wall:
		set_bottom_right(coord, false)

func check_if_top_right_needed(coord) -> void:
	var right = coord + Vector2i(1, 0)
	var up = coord + Vector2i(0, -1)

	var east_wall := not empty_tile(east_wall_layer, coord)
	var north_wall := not empty_tile(north_wall_layer, coord)
	
	var neighbor_east_wall := not empty_tile(east_wall_layer, up)
	var neighbor_north_wall := not empty_tile(north_wall_layer, right)
	 
	if east_wall and north_wall:
		set_top_right(coord, true)
	elif east_wall or north_wall:
		return
	elif neighbor_east_wall or neighbor_north_wall:
		set_top_right(coord, false)

func check_if_top_left_needed(coord) -> void:
	var left = coord + Vector2i(-1, 0)
	var up = coord + Vector2i(0, -1)

	var west_wall := not empty_tile(west_wall_layer, coord)
	var north_wall := not empty_tile(north_wall_layer, coord)
	
	var neighbor_west_wall := not empty_tile(west_wall_layer, up)
	var neighbor_north_wall := not empty_tile(north_wall_layer, left)
	 
	if west_wall and north_wall:
		set_top_left(coord, true)
	elif west_wall or north_wall:
		return
	elif neighbor_west_wall or neighbor_north_wall:
		set_top_left(coord, false)


## Call this function once all the walls are in place
func setup_corners() -> void:
	for coord in base_layer.get_used_cells():
		pass
		#var left = coord + Vector2i(-1, 0)
		#var right = coord + Vector2i(1, 0)
		#var up = coord + Vector2i(0, -1)
		#var down = coord + Vector2i(0, 1)

		check_if_bottom_left_needed(coord)
		check_if_bottom_right_needed(coord)
		check_if_top_right_needed(coord)
		check_if_top_left_needed(coord)


func _on_base_layer_hovering_tile(coord: Vector2i) -> void:
	hovering_tile.emit(coord)
