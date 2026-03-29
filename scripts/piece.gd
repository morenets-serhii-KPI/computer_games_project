extends Node2D

var form = []

const TILE_SIZE = 150
var block_scene = preload("res://scenes/piece_block.tscn")

@onready var collision = $Area2D/CollisionShape2D

static var current_dragged = null

var dragging = false
var drag_offset = Vector2.ZERO

var start_position = Vector2.ZERO
var start_scale = Vector2.ONE
var start_z_index = 0

var pending_shape = null

var board_container = null
var board = null
var game_container = null

var shape_center_offset = Vector2.ZERO


# ================== INIT ==================

func _ready():
	start_position = global_position
	start_scale = scale
	start_z_index = z_index

	if pending_shape != null:
		_apply_shape(pending_shape)


# ================== SETUP ==================

func setup(shape):
	if not is_node_ready():
		pending_shape = shape
	else:
		_apply_shape(shape)


# ================== SHAPE ==================

func _apply_shape(shape):
	form = shape
	_clear_blocks()
	_create_blocks()
	_update_collision()


func _clear_blocks():
	for child in $Blocks.get_children():
		child.queue_free()


func _create_blocks():
	for y in range(form.size()):
		for x in range(form[y].size()):
			if form[y][x] == 1:
				var block = block_scene.instantiate()
				block.position = Vector2(x, y) * TILE_SIZE
				$Blocks.add_child(block)


# ================== COLLISION ==================

func _update_collision():

	if collision == null or collision.shape == null:
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

	var size = Vector2(
		max_x - min_x + TILE_SIZE,
		max_y - min_y + TILE_SIZE
	)

	var padding = TILE_SIZE * 0.5

	collision.shape.size = size + Vector2(padding, padding)
	collision.position = Vector2(
		min_x + size.x / 2,
		min_y + size.y / 2
	)


# ================== INPUT ==================

func _input(event):

	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		return

	if event.pressed:
		_start_drag()
	else:
		_end_drag()


func _start_drag():

	if current_dragged != null or not is_mouse_over():
		return

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	current_dragged = self
	dragging = true

	drag_offset = global_position - get_global_mouse_position()

	scale = Vector2.ONE * board_container.scale.x
	z_index = 100


func _end_drag():

	if not (dragging and current_dragged == self):
		return

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	dragging = false
	current_dragged = null

	if board.locked_highlight_pos != null:
		_place()
	else:
		_reset()


# ================== LOGIC ==================

func _place():

	var grid = board.locked_highlight_pos

	if grid == null:
		_reset()
		return

	board.place_piece(form, grid.x, grid.y)
	board.update_tiles()

	board.on_piece_placed(self)
	board.clear_highlight()


func _reset():

	global_position = start_position
	scale = start_scale
	z_index = start_z_index

	if board != null:
		board.clear_highlight()


# ================== PROCESS ==================

func _process(delta):

	if not (dragging and current_dragged == self):
		return

	var mouse = get_global_mouse_position()

	_update_highlight(mouse)
	global_position = mouse + drag_offset


# ================== HELPERS ==================

func _update_highlight(mouse):

	if board == null:
		return

	var grid = _get_grid_from_mouse(mouse)
	if grid == null:
		return

	var best = board.find_best_position(form, grid.x, grid.y)

	if best != null and abs(best.x - grid.x) + abs(best.y - grid.y) <= 2:
		board.show_highlight(form, best.x, best.y)
	else:
		board.clear_highlight()


func _get_grid_from_mouse(mouse = get_global_mouse_position()):

	if board == null:
		return null

	var local = board.to_local(global_position)

	return Vector2(
		int(local.x / TILE_SIZE),
		int(local.y / TILE_SIZE)
	)


# ================== MOUSE ==================

func is_mouse_over():

	if collision == null or collision.shape == null:
		return false

	var mouse_local = collision.to_local(get_global_mouse_position())

	var rect = collision.shape as RectangleShape2D

	if rect:
		return Rect2(-rect.size / 2, rect.size).has_point(mouse_local)

	return false


func _get_shape_center_offset():

	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF

	for y in range(form.size()):
		for x in range(form[y].size()):
			if form[y][x] == 1:
				min_x = min(min_x, x)
				max_x = max(max_x, x)
				min_y = min(min_y, y)
				max_y = max(max_y, y)

	var center = Vector2(
		(min_x + max_x + 1) / 2.0,
		(min_y + max_y + 1) / 2.0
	)

	return center * TILE_SIZE * scale


func _try_start_drag():

	if current_dragged != null or not is_mouse_over():
		return

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	current_dragged = self
	dragging = true

	shape_center_offset = _get_shape_center_offset()

	scale = Vector2.ONE * board_container.scale.x
	z_index = 100
