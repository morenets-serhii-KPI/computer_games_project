extends Control


@onready var start_ui = $StartUI
@onready var game_container = $GameContainer
@onready var game_over_ui = $GameOverUI

func _ready():
	
	if get_tree().get_meta("replay", false):
		# це реплей → одразу гра
		$StartUI.visible = false
		get_tree().paused = false
		
		# ОБОВ’ЯЗКОВО скинути прапорець
		get_tree().set_meta("replay", false)
	else:
		# перший запуск → показати меню
		$StartUI.visible = true
		get_tree().paused = true
	
	start_ui.play_pressed.connect(start_game)

func start_game():
	var t = create_tween()
	t.tween_property(start_ui, "position:y", -get_viewport_rect().size.y, 0.5)
	
	await t.finished
	start_ui.visible = false
	
	get_tree().paused = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
