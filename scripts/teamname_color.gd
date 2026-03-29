extends PanelContainer
class_name TeamnameColorLabel

@onready var color_rect: ColorRect = $MarginContainer/TeamnameColor/ColorRect
@onready var name_label: RichTextLabel = $MarginContainer/TeamnameColor/NameLabel

var score_text = ""
var score_shown = false
var team_name_string = ""
var _team_color := Color.RED
func set_name_and_color(team_name: String, team_color: Color) -> void:
	if not is_node_ready():
		await ready
	name_label.push_color(team_color)
	name_label.add_text(team_name)
	color_rect.color = team_color
	team_name_string = team_name
	_team_color = team_color

func set_score(score) -> void:
	score_text = score

func show_score() -> void:
	if not score_shown:
		name_label.add_text(": %s" % score_text)
	score_shown = true

func update_name_label(additional_string: String) -> void:
	name_label.text = ""
	name_label.push_color(_team_color)
	name_label.add_text("%s: %s" % [team_name_string, additional_string])
