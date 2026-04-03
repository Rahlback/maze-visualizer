extends VBoxContainer
class_name CommandOutput

@onready var command_used_label: RichTextLabel = $MarginContainer/CommandUsedLabel
@onready var command_output_label: RichTextLabel = $MarginContainer/CommandOutputLabel

func set_command_used(used_command: String) -> void:
	if not is_node_ready():
		await ready
	
	command_used_label.text = used_command
	
func set_command_output(command_output: String) -> void:
	if not is_node_ready():
		await ready
	
	command_output_label.text = command_output
	
