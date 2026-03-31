extends Control

@onready var label: RichTextLabel = $Label
@onready var file_dialog: FileDialog = $FileDialog
@onready var current_dir_label: Label = $VBoxContainer/HBoxContainer/CurrentDirLabel

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


func _on_button_pressed() -> void:
	var output = []
	print(micro_mouse_dir)
	if micro_mouse_dir != "":
		var maze_py_file_location = "%s/maze.py" % micro_mouse_dir
		print(use_wsl)
		if use_wsl:
			maze_py_file_location = "%s/maze.py" % wsl_local_path
			print_debug(OS.execute("CMD.exe", ["/C", "wsl", "python3", maze_py_file_location, "--generate"], output, true))
		# TODO setup actual commands
		label.text = str(output)

func _on_file_dialog_dir_selected(dir: String) -> void:
	micro_mouse_dir = dir
	print(micro_mouse_dir)
	SaveHandler.save_maze_generator_dir(micro_mouse_dir)
