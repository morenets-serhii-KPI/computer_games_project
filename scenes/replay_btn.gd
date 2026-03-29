extends TextureButton

@onready var mat = material

func _ready():
	material = material.duplicate()
	mat = material

	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_exit)
	button_down.connect(_on_down)
	button_up.connect(_on_up)
	
	await get_tree().process_frame
	pivot_offset = size / 2

func _on_hover():
	var t = create_tween()
	t.tween_property(mat, "shader_parameter/hover", 1.0, 0.1)

func _on_exit():
	var t = create_tween()
	t.tween_property(mat, "shader_parameter/hover", 0.0, 0.1)

func _on_down():
	var t = create_tween()
	t.tween_property(self, "scale", Vector2(0.95, 0.95), 0.05)
	mat.set_shader_parameter("pressed", 1.0)

func _on_up():
	var t = create_tween()
	t.tween_property(self, "scale", Vector2(1, 1), 0.08)
	mat.set_shader_parameter("pressed", 0.0)
