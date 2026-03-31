extends Control

@onready var label: RichTextLabel = $Label
@onready var file_dialog: FileDialog = $FileDialog
@onready var current_dir_label: Label = $VBoxContainer/HBoxContainer/CurrentDirLabel
@onready var python_version_line_edit: LineEdit = $VBoxContainer/PythonVersionHBox/PythonVersionLineEdit
@onready var width_spin_box: SpinBox = $VBoxContainer/VBoxContainer/HBoxContainer/WidthSpinBox
@onready var height_spin_box: SpinBox = $VBoxContainer/VBoxContainer/HBoxContainer/HeightSpinBox

var pipe_process
var wsl_localhost = "//wsl.localhost/"
var wsl_default_distro := ""
var use_wsl := false
var wsl_local_path := ""

var micro_mouse_dir := "":
	set(val):
		current_dir_label.text = val
		micro_mouse_dir = val
		
		var find_actual_path = val.replace("//", "/")
		var individual_directories = find_actual_path.split("/")
		if len(individual_directories) == 1:
			return

		if "wsl" in individual_directories[1]:
			individual_directories.remove_at(1)
			individual_directories.remove_at(1)
			wsl_local_path = "/".join(individual_directories)
			use_wsl = true
		
		
## deprecated. Will return the name of the default WSL installation
func get_wsl_default_distro() -> String:
	if pipe_process:
		OS.kill(pipe_process["pid"])
		await get_tree().physics_frame
		
	pipe_process = OS.execute_with_pipe("cmd.exe", ["/C", "wsl", "-l"])
	await get_tree().physics_frame
	var io = pipe_process["stdio"] as FileAccess
	await get_tree().physics_frame
	
	var line = io.get_buffer(3000)
	
	var s = ""
	for p in line:
		if p != 0 and char(p) != "\r":
			s += char(p)

	var lines = s.split("\n")
	lines.remove_at(0)
	wsl_default_distro = ""
	for dist_line in lines:
		if "default" in dist_line.to_lower():
			wsl_default_distro = dist_line
			break
	
	wsl_default_distro = wsl_default_distro.split(" ")[0]
	OS.kill(pipe_process["pid"])
	return wsl_default_distro

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if SaveHandler.maze_generator_dir != "":
		micro_mouse_dir = SaveHandler.maze_generator_dir
		file_dialog.set_current_dir(micro_mouse_dir)

func get_maze_py_file_location() -> String:
	var maze_py_file_location = "%s/maze.py" % micro_mouse_dir
	if use_wsl:
		maze_py_file_location = "%s/maze.py" % wsl_local_path
	
	return maze_py_file_location

func generate_new_map(python_command: String, loops := false, map_size := "") -> String:
	var output = []
	if micro_mouse_dir != "":
		var maze_py_file_location = get_maze_py_file_location()
		var command_args = ["/C"]
		
		if use_wsl:
			command_args.append("wsl")
		
		command_args += [python_command, maze_py_file_location, "--generate"]
		
		if map_size != "":
			command_args.append("--size")
			command_args.append(map_size)
		
		if loops:
			command_args.append("--loops")

		OS.execute("CMD.exe", command_args, output, true)
		
	return "".join(output)

func run_solution(python_command: String, path_to_solution: String, maze_number) -> String:
	var output = []
	if micro_mouse_dir == "":
		var maze_py_file_location = get_maze_py_file_location()
		var command_args = ["/C"]
		
		if use_wsl:
			command_args.append("wsl")
		
		command_args += [python_command, maze_py_file_location, "--run", "maze_%s" % str(maze_number)]
		command_args += ["--solution", path_to_solution]
	
	
	
	return ""

func _on_button_pressed() -> void:
	var python_command := python_version_line_edit.get_text()
	var map_size := "%d,%d" % [width_spin_box.get_value(), height_spin_box.get_value()]
	label.text = generate_new_map(python_command, true, map_size)

func _on_file_dialog_dir_selected(dir: String) -> void:
	micro_mouse_dir = dir
	print(micro_mouse_dir)
	SaveHandler.save_maze_generator_dir(micro_mouse_dir)
