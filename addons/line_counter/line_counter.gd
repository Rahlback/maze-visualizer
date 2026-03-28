@tool
extends EditorPlugin

var dock

func _enter_tree():
	# Initialization of the plugin goes here.
	dock = preload("res://addons/line_counter/LineCounter.tscn").instantiate()
	
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UL, dock)


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_control_from_docks(dock)
	
	dock.free()
