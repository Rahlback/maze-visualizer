extends Node2D
class_name PlayerAnimatorV3

@export var speed_control := 1.0:
	set(val):
		speed_control = val


const POSITION_TRACK = 0
const ROTATION_TRACK = 1
const TURN_90_TIME = 2
const TURN_180_TIME = 3
const MOVE_STRAIGHT_TIME = 1

signal player_animation_done(anim_name: String)
signal player_changed_string(player_string: String)

var moves = {"phase1": [], "phase2": [], "return": []}
var dir_tracker = {	DIR.DOWN: 
					{
						DIR.RIGHT: ROTATE_DIR.LEFT, 
						DIR.LEFT: ROTATE_DIR.RIGHT, 
						DIR.UP: ROTATE_DIR.BACK, 
						DIR.DOWN: ROTATE_DIR.NONE
					},
					DIR.RIGHT:
					{
						DIR.LEFT: ROTATE_DIR.BACK,
						DIR.RIGHT: ROTATE_DIR.NONE,
						DIR.UP: ROTATE_DIR.LEFT,
						DIR.DOWN: ROTATE_DIR.RIGHT
					},
					DIR.UP:
					{
						DIR.LEFT: ROTATE_DIR.LEFT,
						DIR.RIGHT: ROTATE_DIR.RIGHT,
						DIR.UP: ROTATE_DIR.NONE,
						DIR.DOWN: ROTATE_DIR.BACK
					},
					DIR.LEFT:
					{
						DIR.LEFT: ROTATE_DIR.NONE,
						DIR.RIGHT: ROTATE_DIR.BACK,
						DIR.UP: ROTATE_DIR.RIGHT,
						DIR.DOWN: ROTATE_DIR.LEFT
					}
				}
enum DIR {LEFT, RIGHT, UP, DOWN, NONE}
enum ROTATE_DIR {LEFT, RIGHT, BACK, NONE}

var score

var move_index = 0
var current_step = 0
var current_phase = "phase1"
var play_animation := false
var movement_speed := 32
var play_paused := false
var current_player_string := ""

class Move:
	var from: Vector2 = Vector2(-32, -32)
	var to: Vector2 = Vector2(-32, -32)
	var time_step : int = 0
	var time_index : int = 0
	var elapsed_time : float = 0
	var extra_string : String = ""

	func rotation_angle() -> float:
		return from.angle_to_point(to)
	
	func get_direction() -> DIR:
		var x_diff = from.x - to.x
		var y_diff = from.y - to.y
		if x_diff < 0:
			return DIR.RIGHT
		elif x_diff > 0:
			return DIR.LEFT
		elif y_diff < 0:
			return DIR.DOWN
		elif y_diff > 0:
			return DIR.UP
		else:
			return DIR.NONE
	
	func compare_direction(previous_move: Move, dir_tracker):
		var previous_dir = previous_move.get_direction()
		var current_dir = get_direction()
		
		return dir_tracker[previous_dir][current_dir]
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rand_color = Color(randf(), randf(), randf())
	$Sprite2D.set_instance_shader_parameter("replace_color", rand_color)
	$PointLight2D.color = rand_color

func compare_floats(a: float, b: float) -> bool:
	a = wrapf(a, -PI, PI)
	b = wrapf(b, -PI, PI)
	return abs(a - b) < 0.0001

var target = Vector2.ZERO
var time_index = 0
var rotate_first := false
var rotate_degrees_per_second : float = 0
var current_move: Move = null
var rotate_towards: float = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if play_animation and not play_paused:
		if rotate_first:
			var test = rotate_toward(rotation, current_move.rotation_angle(), delta * rotate_degrees_per_second * speed_control)
			rotation = test
			var comp_fl = compare_floats(rotation, current_move.rotation_angle())
			if comp_fl:
				rotate_first = false
		else:
			position = position.move_toward(current_move.to, movement_speed * delta * speed_control)
		if position.is_equal_approx(current_move.to):
			move_index += 1
			
			if move_index >= len(moves[current_phase]):
				play_animation = false
				player_animation_done.emit(current_phase)
			else:
				current_move = moves[current_phase][move_index]
				
				if current_move.extra_string != current_player_string:
					current_player_string = current_move.extra_string
					player_changed_string.emit(current_player_string)

				current_move.elapsed_time = 0
				rotate_first = current_move.time_step > 1.05
				if compare_floats(current_move.rotation_angle(), PI):
					rotate_degrees_per_second = PI / TURN_180_TIME
					
				elif compare_floats(current_move.rotation_angle(), PI/2):
					rotate_degrees_per_second = (PI) / TURN_90_TIME
				

func _physics_process(delta: float) -> void:
	pass

func parse_text(move_filename: String) -> void:
	var file = FileAccess.open(move_filename, FileAccess.READ)
	if not file:
		print_debug("Opening file ", move_filename, " failed: ", FileAccess.get_open_error())

	var move_text = file.get_as_text()
	
	var lines = move_text.split("\n")
	score = lines[0]
	lines.remove_at(0)
	
	var current_pos := Vector2(-32, -32)
	var previous_time : int = -1
	for line in lines:
		if line == "":
			continue

		var new_move = Move.new()
		
		var temp_split = line.split(',')
		var time_index = int(temp_split[0])
		var x = temp_split[2]
		var y = temp_split[1]
		var phase = temp_split[3]
		if len(temp_split) >= 5:
			new_move.extra_string = temp_split[4]

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
	
	position = moves["phase1"][0].to
	rotation = moves["phase1"][1].rotation_angle()


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
	if play_paused:
		play_paused = false
		return
		
	play_animation = true
	current_phase = phase
	move_index = 0
	if moves[current_phase]:
		current_move = moves[current_phase][move_index]
	else:
		set_process(false)
		player_animation_done.emit(current_phase)

func pause_phase() -> void:
	play_paused = not play_paused
	

func reset_phase(phase: String) -> void:
	print("Reset")
	if not moves[phase]:
		set_process(false)
		return
	else:
		set_process(true)
	position = moves[phase][0].to
	rotation = moves[phase][1].rotation_angle()
	current_phase = phase
	move_index = 0
	play_animation = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	player_animation_done.emit(anim_name)

func _on_timer_timeout() -> void:
	#position = moves[current_phase][move_index].to
	pass
	
	#animation_player.play("return")
	#animation_player.queue("return")
	
