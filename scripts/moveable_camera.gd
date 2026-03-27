extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_pressed()
	pass
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("DragCamera"):
			position -= event.relative / zoom
	elif event.is_action_pressed("ZoomIn"):
		zoom += Vector2(0.1, 0.1)
		zoom = zoom.clamp(Vector2(0.1, 0.1), Vector2(10, 10))
	elif event.is_action_pressed("ZoomOut"):
		if zoom != Vector2(0.1, 0.1):
			zoom -= Vector2(0.1, 0.1)
		zoom = zoom.clamp(Vector2(0.1, 0.1), Vector2(10, 10))
		
