extends Panel

@onready var label: RichTextLabel = $Label
@onready var file_dialog: FileDialog = $FileDialog
@onready var current_dir_label: Label = $CurrentDirHBox/CurrentDirLabel
@onready var python_version_line_edit: LineEdit = $VBoxContainer/PythonVersionHBox/PythonVersionLineEdit
@onready var width_spin_box: SpinBox = $VBoxContainer/VBoxContainer/HBoxContainer/WidthSpinBox
@onready var height_spin_box: SpinBox = $VBoxContainer/VBoxContainer/HBoxContainer/HeightSpinBox
@onready var command_run_tab_container: TabContainer = $CommandRunTabContainer
@onready var maze_select_dialog: FileDialog = $MazeSelectDialog
@onready var selected_maze_dir: RichTextLabel = $VBoxContainer/HBoxContainer/SelectedMazeDir

signal map_generated
signal solutions_ran

const COMMAND_OUTPUT = preload("uid://fv6tsipspcrx")

var pipe_process
var wsl_localhost = "//wsl.localhost/"
var wsl_default_distro := ""
var use_wsl := false
var wsl_local_path := ""

var currently_selected_maze_dir := "":
	set(val):
		if wsl_localhost in val:
			currently_selected_maze_dir = convert_path_to_wsl_path(val)
		else:
			currently_selected_maze_dir = val
		if use_wsl:
			currently_selected_maze_dir = convert_windows_drive_path_to_wsl(currently_selected_maze_dir)
		selected_maze_dir.text = currently_selected_maze_dir


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
		else:
			use_wsl = false

func convert_path_to_wsl_path(windows_path: String) -> String:
	var find_actual_path = windows_path.replace("//", "/")
	var individual_directories = find_actual_path.split("/")
	if len(individual_directories) == 1:
		return ""

	if "wsl" in individual_directories[1]:
		individual_directories.remove_at(1)
		individual_directories.remove_at(1)
		return "/".join(individual_directories)
	
	return ""

## Converts Windows paths that start with a drive to a WSL path that starts with
## /mnt/drive/
## Example: C:/Users/Documents -> /mnt/c/Users/Documents
func convert_windows_drive_path_to_wsl(path: String) -> String:
	if ":" in path:
		var drive = "%s" % path[0]
		return path.replace("%s:" % drive, "/mnt/%s" % drive.to_lower())
	return path

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
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if SaveHandler.maze_generator_dir != "":
		micro_mouse_dir = SaveHandler.maze_generator_dir
		file_dialog.set_current_dir(micro_mouse_dir)
		print("Using micro mouse dir: ", micro_mouse_dir)

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

func run_solution(python_command: String, path_to_solution: String, maze_path: String) -> String:
	var output = []
	if micro_mouse_dir != "":
		var maze_py_file_location = get_maze_py_file_location()
		var command_args = ["/C"]
		
		if wsl_localhost in path_to_solution:
			path_to_solution = convert_path_to_wsl_path(path_to_solution)
		
		if wsl_localhost in maze_path:
			maze_path = convert_path_to_wsl_path(maze_path)
		
		if use_wsl:
			command_args.append("wsl")
		
		command_args += [python_command, maze_py_file_location, "--run", maze_path]
		command_args += ["--solution", path_to_solution]
		
		print("Run solution: ", OS.execute("CMD.exe", command_args, output, true))
		output.insert(0, "CMD.exe %s\n\n" % " ".join(command_args))
	else:
		print("No micro mouse dir")
	
	return "".join(output)

func _on_generate_map_button_pressed() -> void:
	var python_command := python_version_line_edit.get_text()
	var map_size := "%d,%d" % [width_spin_box.get_value(), height_spin_box.get_value()]
	label.text = generate_new_map(python_command, true, map_size)
	map_generated.emit()

func _on_file_dialog_dir_selected(dir: String) -> void:
	micro_mouse_dir = dir
	print(micro_mouse_dir)
	SaveHandler.save_maze_generator_dir(micro_mouse_dir)

@onready var solution_files_select_dialog: FileDialog = $SolutionFilesSelectDialog
#@onready var run_solution_output: RichTextLabel = $RunSolutionOutput

func _on_solution_files_select_dialog_files_selected(paths: PackedStringArray) -> void:
	print(paths)
	var python_command := python_version_line_edit.get_text()
	
	var tab_index := 0
	for path in paths:
		var new_command_output : CommandOutput = COMMAND_OUTPUT.instantiate()
		command_run_tab_container.add_child(new_command_output)
		command_run_tab_container.set_tab_title(tab_index, path.get_file().replace(".py", ""))
		tab_index += 1
		var response := run_solution(python_command, path, currently_selected_maze_dir)
		#print(response)
		#run_solution_output.text = response
		#new_command_output.set_command_used()
		if response.length() > 2000:
			var new_response := response.substr(0, 500)
			new_response += "\n\n Skipping lines... \n\n"
			response = response.substr(response.length() - 1500)
			response = new_response + response
			
		new_command_output.set_command_output(response)
	
	if len(paths) > 0:
		solutions_ran.emit()
		


func _on_run_solution_button_pressed() -> void:
	if currently_selected_maze_dir == "":
		return
	solution_files_select_dialog.show()


func _on_close_button_pressed() -> void:
	hide()


func _on_maze_select_dialog_dir_selected(dir: String) -> void:
	currently_selected_maze_dir = dir


func _on_select_maze_button_pressed() -> void:
	maze_select_dialog.show()


func _on_button_pressed() -> void:
	file_dialog.show()
