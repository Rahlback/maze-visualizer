extends Node2D

@onready var label: RichTextLabel = $Control/Label

var micro_mouse_dir := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	var output = []
	if micro_mouse_dir != "":
		var maze_py_file_location = "%s/maze.py" % micro_mouse_dir
		maze_py_file_location = maze_py_file_location.erase(0, 22)
		
		print(OS.execute("CMD.exe", ["/C", "wsl", "python3", maze_py_file_location], output, true))
		label.text = str(output)

func _on_file_dialog_dir_selected(dir: String) -> void:
	micro_mouse_dir = dir
