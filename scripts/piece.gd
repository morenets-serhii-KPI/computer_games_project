extends Node2D

var form = []

const TILE_SIZE = 150
var block_scene = preload("res://scenes/piece_block.tscn")

@onready var collision = $Area2D/CollisionShape2D

# тимчасове збереження shape, якщо setup викликали до ready
var pending_shape = null


static var current_dragged = null
var start_position = Vector2.ZERO


func _ready():

	print($Area2D)
	print($Area2D.input_pickable)
	print($Area2D.monitoring)

	start_position = global_position

	# підключаємо input від Area2D

	if pending_shape != null:
		_apply_shape(pending_shape)


func setup(shape):
	# якщо нода ще не готова — відкладаємо
	if not is_node_ready():
		pending_shape = shape
	else:
		_apply_shape(shape)


func _apply_shape(shape):
	form = shape

	clear_blocks()
	create_blocks()
	update_collision()


func clear_blocks():
	if not has_node("Blocks"):
		return

	for child in $Blocks.get_children():
		child.queue_free()


func create_blocks():
	if not has_node("Blocks"):
		return

	for y in range(form.size()):
		for x in range(form[y].size()):
			if form[y][x] == 1:
				var block = block_scene.instantiate()

				block.position = Vector2(
					x * TILE_SIZE,
					y * TILE_SIZE
				)

				$Blocks.add_child(block)


func get_width_in_tiles():
	var max_width = 0
	for row in form:
		max_width = max(max_width, row.size())
	return max_width


func update_collision():
	if collision == null or collision.shape == null:
		print("❌ collision not ready")
		return

	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF

	for block in $Blocks.get_children():
		var pos = block.position

		min_x = min(min_x, pos.x)
		min_y = min(min_y, pos.y)
		max_x = max(max_x, pos.x)
		max_y = max(max_y, pos.y)

	# розмір фігури
	var width = max_x - min_x + TILE_SIZE
	var height = max_y - min_y + TILE_SIZE

	# padding (10-20%)
	var padding = TILE_SIZE * 0.5

	var size = Vector2(
		width + padding,
		height + padding
	)

	collision.shape.size = size

	# центр по реальній фігурі
	collision.position = Vector2(
		min_x + width / 2,
		min_y + height / 2
	)



var dragging = false
var drag_offset = Vector2.ZERO

func _input(event):

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:

		if event.pressed:

			if current_dragged == null and is_mouse_over():
				current_dragged = self
				dragging = true
				drag_offset = global_position - get_global_mouse_position()

		else:
			if dragging and current_dragged == self:
				dragging = false
				current_dragged = null

				global_position = start_position


func is_mouse_over():

	if collision == null or collision.shape == null:
		return false

	var mouse_global = get_global_mouse_position()

	# переводимо мишку в локальні координати collision
	var mouse_local = collision.to_local(mouse_global)

	# перевірка для RectangleShape2D
	var rect = collision.shape as RectangleShape2D
	if rect:
		var half_size = rect.size / 2
		return Rect2(-half_size, rect.size).has_point(mouse_local)

	return false

func _process(delta):

	if dragging and current_dragged == self:
		global_position = get_global_mouse_position() + drag_offset
		
	queue_redraw()

func _draw():

	if collision == null or collision.shape == null:
		return

	var size = collision.shape.size
	var center = collision.position

	draw_rect(
		Rect2(center - size / 2, size),
		Color(1, 0, 0, 0.3),  # червоний прозорий
		true
	)
