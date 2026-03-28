@tool
extends Control
@onready var rich_text_label = $RichTextLabel

var exclude_directories : Array

var lines_of_code := 0
var lines_of_code_only_written_code := 0
var lines_of_comments := 0
func find_all_script_files(dir):
	var script_files = ["gd"]
	var text_add = ""

	for file in DirAccess.get_files_at(dir):
		if not file.get_extension() in script_files:
			continue

		text_add += "\t" + file
		var s = FileAccess.get_file_as_string(dir + '/' + file)
		
		var split_s = s.split('\n')
		for line in split_s:
			var stripped_s = line.strip_edges()
			if stripped_s:
				lines_of_code_only_written_code += 1
				if stripped_s.begins_with("#"):
					lines_of_comments += 1
		
		var num_of_lines = len(split_s)
		text_add += ": " + str(num_of_lines) + '\n'
		lines_of_code += num_of_lines
	
	if text_add:
		rich_text_label.append_text(dir + "\n")
		rich_text_label.append_text(text_add)
	
	for next_dir in DirAccess.get_directories_at(dir):
		var next_full_dir = dir +'/' + next_dir
		if next_full_dir in exclude_directories:
			continue
		find_all_script_files(next_full_dir)
		

func _on_button_pressed():
	var exclusion_file = FileAccess.get_file_as_string("res://addons/line_counter/exclude_directories.txt")
	exclude_directories = exclusion_file.strip_edges().split('\n')
	
	rich_text_label.text = ""
	rich_text_label.clear()
	lines_of_code = 0
	lines_of_code_only_written_code = 0
	lines_of_comments = 0
	find_all_script_files("res://")
	rich_text_label.push_color(Color.RED)
	rich_text_label.append_text("\nTotal line count: " + str(lines_of_code))
	rich_text_label.append_text("\nLines without whitespace: " + str(lines_of_code_only_written_code))
	rich_text_label.append_text("\nLines of comments: " + str(lines_of_comments))
