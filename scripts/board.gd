extends Node2D

const PieceScene = preload("res://scenes/piece.tscn")
const TileScene = preload("res://scenes/tile.tscn")
const HighlightBlock = preload("res://scenes/piece_block.tscn")
const Shapes = preload("res://scripts/shapes.gd")

const BASE_RESOLUTION = Vector2(1280, 720)
const GRID_W = 8
const GRID_H = 8
const TILE_SIZE = 150
const BOARD_SCALE = 0.5

@onready var board_container = $".."
@onready var pieces_container = $"../../RightPanel/PiecesContainer"
@onready var right_panel = $"../../RightPanel"

var grid = []
var highlights = []

# ================== INIT ==================

func _ready():
	_setup_layout()
	_generate_board()
	_spawn_pieces()


# ================== LAYOUT ==================

func _setup_layout():

	var screen = get_viewport_rect().size

	var scale_factor = min(
		screen.x / BASE_RESOLUTION.x,
		screen.y / BASE_RESOLUTION.y
	) * BOARD_SCALE

	board_container.scale = Vector2(scale_factor, scale_factor)

	pieces_container.scale = Vector2.ONE

	board_container.position = Vector2(
		screen.x * 0.02,
		screen.y * 0.1
	)

	pieces_container.position = Vector2.ZERO


# ================== BOARD ==================

func _generate_board():

	grid.clear()

	for y in range(GRID_H):

		var row = []

		for x in range(GRID_W):

			var tile = TileScene.instantiate()
			tile.position = Vector2(x, y) * TILE_SIZE
			tile.z_index = 1

			add_child(tile)

			row.append(0)

		grid.append(row)


# ================== PIECES ==================

func _spawn_pieces():

	_clear_pieces()

	var shapes = _generate_shapes(3)

	var layout = _calculate_piece_layout()

	for i in range(3):
		_create_piece(shapes[i], i, layout)

	await get_tree().process_frame

	if _is_game_over():
		print("GAME OVER")


func _clear_pieces():
	for c in pieces_container.get_children():
		c.queue_free()


func _generate_shapes(count):

	var result = []

	for i in range(count):
		var group = Shapes.FORMS.pick_random()
		result.append(group.pick_random())

	return result


func _calculate_piece_layout():

	var panel_w = right_panel.size.x
	var panel_h = right_panel.size.y

	var margin_x = panel_w * 0.08
	var usable_width = panel_w - margin_x * 2

	var spacing = panel_w * 0.02

	var scale = (usable_width - spacing * 2) / (3 * 5 * TILE_SIZE)

	var max_height = panel_h * 0.25
	var scale_h = max_height / (5 * TILE_SIZE)

	scale = min(scale, scale_h)

	return {
		"scale": scale,
		"margin_x": margin_x,
		"slot_width": usable_width / 3.0,
		"base_y": panel_h * 0.65
	}


func _create_piece(shape, index, layout):

	var piece = PieceScene.instantiate()

	piece.board = self
	piece.board_container = board_container
	piece.game_container = $"../.."

	piece.setup(shape)
	piece.scale = Vector2(layout.scale, layout.scale)

	var center_offset = _get_shape_center_offset(shape, layout.scale)

	var slot_x = layout.margin_x + layout.slot_width * (index + 0.5)
	var slot_pos = Vector2(slot_x, layout.base_y)

	piece.position = slot_pos - center_offset

	pieces_container.add_child(piece)


func _get_shape_center_offset(shape, scale):

	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF

	for y in range(shape.size()):
		for x in range(shape[y].size()):
			if shape[y][x] == 1:
				min_x = min(min_x, x)
				max_x = max(max_x, x)
				min_y = min(min_y, y)
				max_y = max(max_y, y)

	var center = Vector2(
		(min_x + max_x + 1) / 2.0,
		(min_y + max_y + 1) / 2.0
	)

	return center * TILE_SIZE * scale


# ================== GAME LOGIC ==================

func can_place(shape, grid_x, grid_y):

	for y in range(shape.size()):
		for x in range(shape[y].size()):

			if shape[y][x] == 1:

				var bx = grid_x + x
				var by = grid_y + y

				if bx < 0 or by < 0 or bx >= GRID_W or by >= GRID_H:
					return false

				if grid[by][bx] == 1:
					return false

	return true


func place_piece(shape, grid_x, grid_y):

	for y in range(shape.size()):
		for x in range(shape[y].size()):
			if shape[y][x] == 1:
				grid[grid_y + y][grid_x + x] = 1


func update_tiles():

	var i = 0

	for y in range(GRID_H):
		for x in range(GRID_W):

			var tile = get_child(i)
			tile.set_filled(grid[y][x] == 1)

			i += 1


func on_piece_placed(piece):

	piece.queue_free()
	
	clear_lines()
	update_tiles()

	await get_tree().process_frame

	if pieces_container.get_child_count() > 0:

		if _is_game_over():
			print("GAME OVER")
			return

	if pieces_container.get_child_count() == 0:
		_spawn_pieces()


func _is_game_over():

	for piece in pieces_container.get_children():

		var shape = piece.form

		for y in range(GRID_H):
			for x in range(GRID_W):
				if can_place(shape, x, y):
					return false

	return true


# ================== HIGHLIGHT ==================

func show_highlight(shape, grid_x, grid_y):

	clear_highlight()

	var cell_offset = Vector2(12, 12)      # вирівнювання в клітинці

	for y in range(shape.size()):
		for x in range(shape[y].size()):

			if shape[y][x] != 1:
				continue

			var bx = grid_x + x
			var by = grid_y + y

			if bx < 0 or by < 0 or bx >= GRID_W or by >= GRID_H:
				continue

			var block = HighlightBlock.instantiate()

			block.position = Vector2(bx, by) * TILE_SIZE + cell_offset 
			block.modulate = Color(1, 1, 1, 0.35)

			add_child(block)
			highlights.append(block)


func clear_highlight():

	for h in highlights:
		h.queue_free()

	highlights.clear()


# ================== UTILS ==================

func is_inside(mouse_global):

	var local = to_local(mouse_global)

	return (
		local.x >= 0 and local.y >= 0 and
		local.x < GRID_W * TILE_SIZE and
		local.y < GRID_H * TILE_SIZE
	)



func clear_lines():

	var rows_to_clear = []
	var cols_to_clear = []

	# --- перевірка рядків ---
	for y in range(GRID_H):
		var full = true
		for x in range(GRID_W):
			if grid[y][x] == 0:
				full = false
				break
		if full:
			rows_to_clear.append(y)

	# --- перевірка колонок ---
	for x in range(GRID_W):
		var full = true
		for y in range(GRID_H):
			if grid[y][x] == 0:
				full = false
				break
		if full:
			cols_to_clear.append(x)

	# --- очищення ---
	for y in rows_to_clear:
		for x in range(GRID_W):
			grid[y][x] = 0

	for x in cols_to_clear:
		for y in range(GRID_H):
			grid[y][x] = 0
