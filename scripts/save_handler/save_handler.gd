extends Node

const SaveData = preload("uid://bmbvhhtu5dmcs")
const file_save_location := "user://save_data.json"

var maze_data_dir_key := "maze_output_directory"
var maze_generator_dir_key := "maze_generator_dir_key"

var save_data_dict = 	{
							maze_data_dir_key: "",
							maze_generator_dir_key: ""
						}

var maze_map_data_dir := ""
var maze_generator_dir := ""

func _ready() -> void:
	# Load save data if it exists
	load_saved_data()

func load_saved_data() -> void:
	if not FileAccess.file_exists(file_save_location):
		return

	var save_file := FileAccess.get_file_as_string(file_save_location)
	save_data_dict = JSON.parse_string(save_file)
	maze_map_data_dir = save_data_dict[maze_data_dir_key]
	maze_generator_dir = save_data_dict[maze_generator_dir_key]
	
func save_data() -> void:
	var file_access = FileAccess.open(file_save_location, FileAccess.WRITE)
	save_data_dict[maze_data_dir_key] = maze_map_data_dir
	save_data_dict[maze_generator_dir_key] = maze_generator_dir
	file_access.store_string(JSON.stringify(save_data_dict, "\t"))
	

func save_maze_map_data_dir(new_maze_location: String):
	maze_map_data_dir = new_maze_location
	save_data()

func save_maze_generator_dir(new_maze_generator_location: String):
	maze_generator_dir = new_maze_generator_location
	save_data()
