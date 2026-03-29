extends TileMapLayer

signal hovering_tile(coord: Vector2i)

var currently_hovering = Vector2i(-1, -1)
const NO_TILE = Vector2i(-1, -1)

func _physics_process(_delta: float) -> void:
	var local_mouse = get_local_mouse_position()
	var coordinate_space = local_to_map(local_mouse)
	
	if get_cell_atlas_coords(coordinate_space) != NO_TILE:
		if coordinate_space != currently_hovering:
			currently_hovering = coordinate_space
			hovering_tile.emit(currently_hovering)
