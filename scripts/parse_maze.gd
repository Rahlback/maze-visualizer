extends Node2D
class_name MazeParser

@onready var maze_viewer: MazeView = $MazeViewer

const MAZE_DATA_PATH := "C:\\Users\\jjy322\\OneDrive - AFRY\\Documents\\code_challenge\\maze_data"
var test_map := "res://test_docs/map1_test.txt"
const test_map_2 = "res://test_docs/mazes/maze1/map.txt"

const NORTH_WALL = 1
const EAST_WALL = 2
const SOUTH_WALL = 4
const WEST_WALL = 8

var middle_coord := Vector2i(0, 0)

func test():
	#var dir = DirAccess.get_directories_at(MAZE_DATA_PATH)
	#print(dir)
	return parse_map_data(test_map_2)

func parse_map_data(filename: String):
	var file = FileAccess.open(filename, FileAccess.READ)
	if not file:
		print_debug("Opening file ", filename, " failed: ", FileAccess.get_open_error())
		return null
	
	var file_text = file.get_as_text()
	
	
	var coord = Vector2i(0, 0)
	for line: String in file_text.split("\n"):
		if line:
			coord.x = 0
			for c: String in line:
				maze_viewer.set_base_tile(coord)
				var cell_int := c.unicode_at(0)
				if cell_int & EAST_WALL:
					maze_viewer.set_east_wall(coord)
				if cell_int & WEST_WALL:
					maze_viewer.set_west_wall(coord)
				if cell_int & SOUTH_WALL:
					maze_viewer.set_south_wall(coord)
				if cell_int & NORTH_WALL:
					maze_viewer.set_north_wall(coord)
				if cell_int & 32:
					#print("Center -> ", coord)
					middle_coord = coord
				coord.x += 1

		coord.y += 1
	maze_viewer.setup_corners()
	queue_redraw()


func _draw() -> void:
	if middle_coord != Vector2i.ZERO:
		#print(middle_coord * 8)
		pass
		#draw_circle(middle_coord * 32 + Vector2i(16, 16), 10, Color.RED)





pass
