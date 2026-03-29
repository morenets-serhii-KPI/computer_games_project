extends CanvasLayer

@onready var panel = $Panel
@onready var dim = $Dim

func _ready():
	visible = false


func show_game_over():

	visible = true

	# стартовий стан
	panel.scale = Vector2(0.5, 0.5)
	panel.modulate.a = 0
	dim.modulate.a = 0

	# tween
	var t = create_tween()

	t.parallel().tween_property(dim, "modulate:a", 0.4, 0.3)

	t.parallel().tween_property(panel, "scale", Vector2(1.1, 1.1), 0.25)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	t.parallel().tween_property(panel, "modulate:a", 1.0, 0.2)

	t.chain().tween_property(panel, "scale", Vector2(1,1), 0.1)
