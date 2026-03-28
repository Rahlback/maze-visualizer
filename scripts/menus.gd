extends CanvasLayer

@onready var file_dialog: FileDialog = $FileDialog
@onready var playback_speed_label: RichTextLabel = $Menus/VBoxContainer/PlaybackSpeedLabel
@onready var play_button: Button = $Menus/VBoxContainer/HBoxContainer/PlayButton
@onready var play_debounce: Timer = $PlayDebounce

signal file_dialog_dir_selected(dir: String)
signal play_button_pressed
signal pause_button_pressed
signal playback_speed_changed(speed: float)

var prevent_play_pressed := true

var speed : float = 1:
	set(val):
		#val = clampf(val, 1.0/4.0, 16)
		speed = val
		playback_speed_label.text = "Playback speed: " + str(roundf(speed * 100) / 100.0) + "x"
		playback_speed_changed.emit(speed)
		
const speed_step : float = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_load_maps_button_up() -> void:
	file_dialog.popup_centered()


func _on_file_dialog_dir_selected(dir: String) -> void:
	print("Selected directory: ", dir)
	file_dialog_dir_selected.emit(dir)
	await get_tree().physics_frame
	playback_speed_changed.emit(speed)
	


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
