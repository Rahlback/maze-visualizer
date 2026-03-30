extends CanvasLayer

@onready var file_dialog: FileDialog = $FileDialog
@onready var playback_speed_label: RichTextLabel = $Menus/VBoxContainer/PlaybackSpeedLabel
@onready var play_button: Button = $Menus/VBoxContainer/HBoxContainer/PlayButton
@onready var play_debounce: Timer = $PlayDebounce
@onready var auto_reload_checkbox: CheckBox = $Menus/VBoxContainer/HBoxContainer2/AutoReloadCheckbox
@onready var auto_reload_timer: Timer = $AutoReloadTimer
@onready var game_menu_panel: PanelContainer = $Menus/GameMenuPanel

signal file_dialog_dir_selected(dir: String)
signal play_button_pressed
signal pause_button_pressed
signal playback_speed_changed(speed: float)
signal reload_button_pressed

var prevent_play_pressed := true
var auto_reload := false
var monitor_dir := "":
	set(val):
		monitor_dir = val
		setup_monitor(val)

var files_latest_modified = {} 
var dir_loaded := ""

var speed : float = 1:
	set(val):
		#val = clampf(val, 1.0/4.0, 16)
		speed = val
		playback_speed_label.text = "Playback speed: " + str(roundf(speed * 100) / 100.0) + "x"
		playback_speed_changed.emit(speed)
		
const speed_step : float = 2

func setup_monitor(dir: String):
	var files = DirAccess.get_files_at(dir)
	files_latest_modified = {}
	for file in files:
		files_latest_modified[file] = FileAccess.get_modified_time(dir + "/" + file)
	print(files_latest_modified)

func check_if_files_updated():
	var files = DirAccess.get_files_at(monitor_dir)
	
	for file in files:
		var modified_time = FileAccess.get_modified_time(monitor_dir + "/" + file)
		if not file in files_latest_modified or files_latest_modified[file] != modified_time:
			await _on_file_dialog_dir_selected(monitor_dir)
			await get_tree().physics_frame
			_on_play_button_pressed()
			return


	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	auto_reload = auto_reload_checkbox.button_pressed
	if SaveHandler.maze_map_data_dir != "":
		file_dialog.set_current_dir(SaveHandler.maze_map_data_dir)
		print("Loading map data from: ", SaveHandler.maze_map_data_dir)
	else:
		print("Save handler does not have anything: ", SaveHandler.maze_map_data_dir)
	

func _on_load_maps_button_up() -> void:
	file_dialog.popup_centered()


func _on_file_dialog_dir_selected(dir: String) -> void:
	print("Selected directory: ", dir)
	file_dialog_dir_selected.emit(dir)
	monitor_dir = dir
	await get_tree().physics_frame
	playback_speed_changed.emit(speed)
	SaveHandler.save_maze_map_data_dir(dir)
	


func _on_play_button_pressed() -> void:
	#if not play_button.disabled:
	play_button_pressed.emit()
	#play_button.disabled = true
	#play_debounce.start()

func _on_speed_down_button_pressed() -> void:
	speed /= speed_step

func _on_pause_button_pressed() -> void:
	pause_button_pressed.emit()

func _on_speed_up_button_pressed() -> void:
	speed *= speed_step

func _on_reverse_button_pressed() -> void:
	speed = -absf(speed)

func _on_forward_button_pressed() -> void:
	speed = absf(speed)
	

func _on_play_debounce_timeout() -> void:
	play_button.disabled = false


func _on_auto_reload_checkbox_toggled(toggled_on: bool) -> void:
	auto_reload = toggled_on

	if auto_reload:
		auto_reload_timer.start()
	else:
		auto_reload_timer.stop()

func _on_auto_reload_timer_timeout() -> void:
	if auto_reload and monitor_dir != "":
		check_if_files_updated()

func _on_reload_button_pressed() -> void:
	reload_button_pressed.emit()

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_game_menu_button_pressed() -> void:
	game_menu_panel.visible = not game_menu_panel.visible

func _on_close_menu_button_pressed() -> void:
	_on_game_menu_button_pressed()
