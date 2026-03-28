extends Node2D

@export var auto_play_phases := true
@export var player_colors : PackedColorArray
var current_color = 0
var teamnames_and_color = {}
var current_time: float = 0
var speed_control: float = 1

var teams_finished_with_phase := 0
var team_names_score = {}
var phases = ["phase1", "return", "phase2"]
var current_phase = -2

var maze_parser: MazeParser
const MAZE_PARSER = preload("uid://cej1anuir2xdj")
const PLAYER = preload("uid://dy82vcicyhrsd")
const TEAMNAME_COLOR = preload("uid://b4tgg06vigtud")

#@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var map_holder: Node2D = $MapHolder
@onready var menus: Control = $CanvasLayer2/Menus
@onready var teams_box: VBoxContainer = $Teams/TeamsBox
@onready var label: Label = $Teams/Label
@onready var time_label: RichTextLabel = $Teams/TimeLabel

func _physics_process(delta: float) -> void:
	current_time += delta * speed_control
	time_label.text = "%.1f" % current_time


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#maze_parser = MAZE_PARSER.instantiate()
	#map_holder.add_child(maze_parser)
	pass
	#maze_parser_ready()
	#sub_viewport.world_2d = get_viewport().world_2d

func maze_parser_ready():
	maze_parser.test()

func start_current_phase() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ShowMenu"):
		menus.visible = not menus.visible

func _on_canvas_layer_2_file_dialog_dir_selected(dir: String) -> void:
	print("Received dir string ", dir)
	var maze_folder := DirAccess.open(dir)
	if maze_folder.file_exists("map.txt"):
		current_phase = -2
		current_color = 0
		for child in map_holder.get_children():
			child.queue_free()
		
		for child in teams_box.get_children():
			child.queue_free()

		var new_maze_parser : MazeParser = MAZE_PARSER.instantiate()
		map_holder.add_child(new_maze_parser)
		new_maze_parser.parse_map_data(dir + "/map.txt")
		
		for filename in maze_folder.get_files():
			if filename.begins_with("team_"):
				var new_player : PlayerAnimatorV3 = PLAYER.instantiate()
				map_holder.add_child(new_player)
				var team_name = filename.erase(0, 5)
				team_name = team_name.get_basename()
				if current_color >= len(player_colors):
					var rand_color: Color = Color(randf(), randf(), randf())
					new_player.set_color(rand_color)
					teamnames_and_color[team_name] = rand_color
				else:
					new_player.set_color(player_colors[current_color])
					teamnames_and_color[team_name] = player_colors[current_color]
				current_color += 1
				new_player.parse_text(dir + "/" + filename)
				new_player.player_animation_done.connect(team_finished_phase)
				team_names_score[team_name] = new_player.score
				
		for key in teamnames_and_color.keys():
			var new_team: TeamnameColorLabel = TEAMNAME_COLOR.instantiate()
			new_team.set_name_and_color(key, teamnames_and_color[key])
			new_team.set_score(team_names_score[key])
			teams_box.add_child(new_team)

func play_next_phase() -> void:
	if current_phase == len(phases):
		#current_phase = -1
		print_debug("Abort play. Already played")
		return
	
	for child in map_holder.get_children():
		if child is PlayerAnimatorV3:
			child.play_phase(phases[current_phase])
	
	label.text = phases[current_phase]
	current_time = 0

func team_finished_phase(_anim_name: String) -> void:
	teams_finished_with_phase += 1
	print("Teams finished with phase: " + str(phases[current_phase]) + " = " + str(teams_finished_with_phase))
	if teams_finished_with_phase == len(teamnames_and_color):
		teams_finished_with_phase = 0
		if current_phase == 2:
			for child in teams_box.get_children():
				child.show_score()
			current_phase = -2
		else:
			current_phase += 1
			if auto_play_phases:
				play_next_phase()

func reset_players(phase) -> void:
	teams_finished_with_phase = 0
	for child in map_holder.get_children():
		if child is PlayerAnimatorV3:
			child.reset_phase(phases[phase])


func _on_canvas_layer_2_play_button_pressed() -> void:
	time_label.show()
	current_time = 0
	
	if current_phase == -2:
		current_phase = 0
	else:
		current_phase = wrapi(current_phase+1, 0, 3)

	reset_players(current_phase)

	for child in map_holder.get_children():
		if child is PlayerAnimatorV3:
			child.play_phase(phases[current_phase])
	if current_phase == -1 or current_phase >= len(phases):
		current_phase = 0
		label.text = "reset"
	else:
		label.text = phases[current_phase]

func _on_canvas_layer_2_playback_speed_changed(speed: float) -> void:
	speed_control = speed
	for child in map_holder.get_children():
		if child is PlayerAnimatorV3:
			child.speed_control = speed

func _on_canvas_layer_2_pause_button_pressed() -> void:
	for child in map_holder.get_children():
		if child is PlayerAnimatorV3:
			child.pause_phase()
