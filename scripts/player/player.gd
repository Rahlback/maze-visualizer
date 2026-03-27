extends Node2D
class_name Player

##### USE Jersey 10 on google fonts

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var score = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self_modulate = Color(randi() % 255, randi() % 255, randi() % 255)
	parse_text(FileAccess.open("res://test_docs/team_testteam1.txt", FileAccess.READ).get_as_text())
	#var c = animation_player.get_animation("phase1")
	#c.track_insert_key(1, 5, -PI)
	animation_player.play("phase1")
	#animation_player.queue("return")
	#print(animation_player.get_animation("phase1").track_get_key_count(0))
	animation_player.speed_scale = 5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$CanvasLayer/Label.text = str(animation_player.current_animation_position)

func parse_text(move_text: String) -> void:
	var lines = move_text.split("\n")
	score = lines[0].split(',')
	lines.remove_at(0)
	
	var current_phase = ""
	var current_animation : Animation = null
	var previous_time_index = 0
	var previous_position = Vector2(-32, -32)
	var previous_direction = 0
	var time_index_offset = -1
	for line in lines:
		if not line:
			break
		var temp_list = line.split(",")
		var time_index = float(temp_list[0])
		var x = temp_list[1]
		var y = temp_list[2]
		var phase = temp_list[3]

		if phase != current_phase:
			current_phase = phase
			if current_animation:
				current_animation.track_insert_key(1, 0, previous_direction)
				current_animation.length = time_index+1
				
			current_animation = animation_player.get_animation(phase)
			#if previous_position != Vector2(-32, -32):
			time_index_offset = time_index - 1
			previous_time_index = 0
			
				#current_animation.track_insert_key(0, 0, previous_position)
			
		#print("Adding key: ", float(time_index), " ",32*Vector2(int(x), int(y)))
		time_index -= time_index_offset
		var next_position = 32*Vector2(int(x) + 0.5, int(y) + 0.5)
		
		if time_index - previous_time_index > 1.1:
			var direction = previous_position.angle_to_point(next_position)
			print(time_index-1, ": ", next_position)
			current_animation.track_insert_key(0, time_index-1, previous_position)
			current_animation.track_insert_key(1, previous_time_index, previous_direction)
			current_animation.track_insert_key(1, time_index-1, direction)
			previous_direction = direction

		print(time_index, ": ", next_position)
		current_animation.track_insert_key(0, time_index, next_position)
		previous_position = next_position
		previous_time_index = time_index
		
	current_animation.length = float(previous_time_index)
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print("Animation done: ", anim_name)
	if anim_name == "phase1":
		var anim : Animation = animation_player.get_animation("return")
		for x in range(anim.track_get_key_count(0)):
			var val = anim.track_get_key_value(0, x)
			var time = anim.track_get_key_time(0, x)
			print(time, ": ", val)
		
		for x in range(anim.track_get_key_count(1)):
			var val = anim.track_get_key_value(1, x)
			var time = anim.track_get_key_time(1, x)
			print(time, ": ", val)
		animation_player.play("return")
	else:
		var anim : Animation = animation_player.get_animation("phase1")
		for x in range(anim.track_get_key_count(0)):
			var val = anim.track_get_key_value(0, x)
			var time = anim.track_get_key_time(0, x)
			print(time, ": ", val)
		
		for x in range(anim.track_get_key_count(1)):
			var val = anim.track_get_key_value(1, x)
			var time = anim.track_get_key_time(1, x)
			print(time, ": ", val)
		animation_player.play("phase1")
		
