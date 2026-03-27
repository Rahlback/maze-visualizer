extends Node2D
class_name PlayerAnimator

@export var speed_control := 1.0:
	set(val):
		if animation_player:
			animation_player.speed_scale = val
		speed_control = val

@onready var animation_player: AnimationPlayer = $AnimationPlayer

const POSITION_TRACK = 0
const ROTATION_TRACK = 1

signal player_animation_done(anim_name: String)

var moves = {"phase1_unique": [], "phase2_unique": [], "return_unique": []}
var score

var current_step = 0
var current_phase = "phase1_unique"
class Move:
	var from: Vector2 = Vector2(-32, -32)
	var to: Vector2 = Vector2(-32, -32)
	var time_step : int = 0
	var time_index : int = 0

	func rotation_angle() -> float:
		return from.angle_to_point(to)

func create_anim(anim_name: String) -> Animation:
	var anim_p1 = Animation.new()
	var index = anim_p1.add_track(Animation.TYPE_VALUE)
	anim_p1.track_set_path(index, ".:position")
	var index2 = anim_p1.add_track(Animation.TYPE_VALUE)
	anim_p1.track_set_path(index2, ".:rotation")
	return anim_p1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rand_color = Color(randf(), randf(), randf())

	$Sprite2D.set_instance_shader_parameter("replace_color", rand_color)
	#parse_text(FileAccess.open("res://test_docs/team_testteam1.txt", FileAccess.READ).get_as_text())
	#var c = animation_player.get_animation("phase1")
	#c.track_insert_key(1, 5, -PI)
	#animation_player.queue("return")
	#print(animation_player.get_animation("phase1").track_get_key_count(0))
	$PointLight2D.color = rand_color
	var anim_lib = AnimationLibrary.new()

	var anim_p1 = create_anim("phase1_unique")
	var anim_p2 = create_anim("phase2_unique")
	var anim_return = create_anim("return_unique")
	anim_lib.add_animation("phase1_unique", anim_p1)
	anim_lib.add_animation("phase2_unique", anim_p2)
	anim_lib.add_animation("return_unique", anim_return)
	
	animation_player.add_animation_library("wut", anim_lib)
	#animation_player.set_animation("phase1_unique") = anim_p1
	#animation_player.animations["phase2_unique"] = anim_p2
	#animation_player.animations["return_unique"] = anim_r
	
	#animation_player.play("phase1")
	#animation_player.queue("return")
	animation_player.speed_scale = speed_control
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if animation_player.is_playing():
		$CanvasLayer/Label.text = str(animation_player.current_animation_position)


func parse_text(move_filename: String) -> void:
	
	var file = FileAccess.open(move_filename, FileAccess.READ)
	if not file:
		print_debug("Opening file ", move_filename, " failed: ", FileAccess.get_open_error())

	var move_text = file.get_as_text()
	
	var lines = move_text.split("\n")
	score = lines[0].split(',')
	lines.remove_at(0)
	
	var current_pos := Vector2(-32, -32)
	var previous_time : int = -1
	for line in lines:
		if line == "":
			continue

		var new_move = Move.new()
		
		var temp_split = line.split(',')
		var time_index = int(temp_split[0])
		var x = temp_split[1]
		var y = temp_split[2]
		var phase = temp_split[3] + "_unique"

		var next_position = 32*Vector2(int(x) + 0.5, int(y) + 0.5)

		# First position
		new_move.to = next_position
		new_move.time_index = time_index
		if current_pos != Vector2(-32, -32):
			new_move.from = current_pos
			new_move.time_step = time_index - previous_time
		else:
			new_move.time_step = 0
	
		moves[phase].append(new_move)
		previous_time = time_index
		current_pos = next_position
	
	var angle: float = 0.0
	if len(moves["phase1_unique"]) >= 2:
		var second_pos: Move = moves["phase1_unique"][1]
		angle = second_pos.rotation_angle()
		
	angle = setup_animation("phase1_unique", angle)
	
	angle = setup_animation("return_unique", angle)
	
	angle = setup_animation("phase2_unique", angle)
	
	position = moves["phase1_unique"][0].to
	rotation = moves["phase1_unique"][1].rotation_angle()

func setup_animation(anim_name: String, previous_angle: float) -> float:
	var previous_move: Move = null
	var first_move: Move = moves[anim_name][0]
	var time_offset = first_move.time_index
	for move: Move in moves[anim_name]:
		var animation = animation_player.get_animation(anim_name)
		if move.time_step == 0:
			animation.track_insert_key(POSITION_TRACK, 0, move.to)
			animation.track_insert_key(ROTATION_TRACK, 0, previous_angle)
			#position = move.to
			#rotation = previous_angle
		else:
			if move.time_step > 1.1:
				# Turning left
				var next_rotation = move.rotation_angle()
				#if next_direction == DIR.LEFT && previous_direction == DIR.UP:
					#next_rotation = previous_angle - PI/2
				#elif next_direction == DIR.UP && previous_direction == DIR.LEFT:
					#next_rotation = previous_angle + PI/2
				#elif next_direction == DIR.RIGHT && previous_direction == DIR.UP:
					#next_rotation = previous_angle 
				
				animation.track_insert_key(ROTATION_TRACK, move.time_index-3 - time_offset, previous_angle)
				animation.track_insert_key(ROTATION_TRACK, move.time_index-1- time_offset, next_rotation)
				animation.track_insert_key(POSITION_TRACK, move.time_index-1- time_offset, move.from)
				previous_angle = next_rotation
			animation.track_insert_key(POSITION_TRACK, move.time_index- time_offset, move.to)
			
		previous_move = move
		animation.length = move.time_index - time_offset
	
	return previous_angle

enum DIR {LEFT, RIGHT, UP, DOWN}

func get_direction(angle: float) -> DIR:
	var epsilon = 0.0001
	if (angle - -PI/2) < epsilon: # UP
		return DIR.UP
	elif (angle - PI/2) < epsilon: # DOWN
		return DIR.DOWN
	elif (angle - PI) < epsilon: # LEFT
		return DIR.LEFT
	else:
		return DIR.RIGHT

func set_color(player_color: Color):
	$Sprite2D.set_instance_shader_parameter("replace_color", player_color)
	$PointLight2D.color = player_color

func play_phase(phase: String):
	if animation_player.has_animation(phase + "_unique"):
		animation_player.play(phase + "_unique")
	else:
		print_debug("Player does not have animation!")
		print_debug(animation_player.get_animation_library_list())

func pause_animation():
	animation_player.pause()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	player_animation_done.emit(anim_name)
	#if anim_name == "phase1":
		#animation_player.play("return")
	#else:
		#animation_player.play("phase1")
		


func _on_timer_timeout() -> void:
	animation_player.play("return_unique")
	#animation_player.queue("return")
	
