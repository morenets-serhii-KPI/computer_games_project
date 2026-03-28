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

var current_highlight_pos = null
var locked_highlight_pos = null

var cell_offset = Vector2(TILE_SIZE, TILE_SIZE) * 0.12

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

	board_container.position = Vector2(screen.x * 0.02, screen.y * 0.1)
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

	var layout = _calculate_piece_layout()

	for i in range(3):
		var shape = Shapes.FORMS.pick_random().pick_random()
		_create_piece(shape, i, layout)

	await get_tree().process_frame

	if _is_game_over():
		print("GAME OVER")


func _clear_pieces():
	for c in pieces_container.get_children():
		c.queue_free()


func _calculate_piece_layout():

	var panel_w = right_panel.size.x
	var panel_h = right_panel.size.y

	var margin_x = panel_w * 0.08
	var usable_width = panel_w - margin_x * 2
	var spacing = panel_w * 0.02

	var scale = (usable_width - spacing * 2) / (3 * 5 * TILE_SIZE)

	var max_height = panel_h * 0.25
	scale = min(scale, max_height / (5 * TILE_SIZE))

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

			if shape[y][x] != 1:
				continue

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

	if pieces_container.get_child_count() == 0:
		_spawn_pieces()
	elif _is_game_over():
		print("GAME OVER")


func _is_game_over():

	for piece in pieces_container.get_children():
		for y in range(GRID_H):
			for x in range(GRID_W):
				if can_place(piece.form, x, y):
					return false

	return true


# ================== HIGHLIGHT ==================

func show_highlight(shape, grid_x, grid_y):

	clear_highlight()

	if not can_place(shape, grid_x, grid_y):
		return

	var pos = Vector2(grid_x, grid_y)

	current_highlight_pos = pos
	locked_highlight_pos = pos

	for y in range(shape.size()):
		for x in range(shape[y].size()):

			if shape[y][x] != 1:
				continue

			var bx = grid_x + x
			var by = grid_y + y

			var block = HighlightBlock.instantiate()
			block.position = Vector2(bx, by) * TILE_SIZE + cell_offset
			block.modulate = Color(1, 1, 1, 0.35)

			add_child(block)
			highlights.append(block)


func clear_highlight():

	for h in highlights:
		h.queue_free()

	highlights.clear()

	current_highlight_pos = null
	locked_highlight_pos = null 


# ================== LINES ==================

func clear_lines():

	var rows = []
	var cols = []

	for y in range(GRID_H):
		if grid[y].all(func(v): return v == 1):
			rows.append(y)

	for x in range(GRID_W):
		var full = true
		for y in range(GRID_H):
			if grid[y][x] == 0:
				full = false
				break
		if full:
			cols.append(x)

	for y in rows:
		for x in range(GRID_W):
			grid[y][x] = 0

	for x in cols:
		for y in range(GRID_H):
			grid[y][x] = 0


# ================== SMART SNAP ==================

func find_best_position(shape, gx, gy):

	gx = clamp(gx, 0, GRID_W - 1)
	gy = clamp(gy, 0, GRID_H - 1)

	var best_pos = null
	var best_score = -INF

	for r in range(5):
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):

				var nx = gx + dx
				var ny = gy + dy

				if not can_place(shape, nx, ny):
					continue

				var score = _score_position(shape, nx, ny, gx, gy)
				score -= (abs(dx) + abs(dy)) * 0.1

				if score > best_score:
					best_score = score
					best_pos = Vector2(nx, ny)

	return best_pos


func _score_position(shape, gx, gy, base_gx, base_gy):

	var score = 0
	var overlap = 0

	for y in range(shape.size()):
		for x in range(shape[y].size()):

			if shape[y][x] != 1:
				continue

			var bx = gx + x
			var by = gy + y

			if bx == base_gx + x and by == base_gy + y:
				overlap += 1

			for n in [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]:

				var nx = bx + n.x
				var ny = by + n.y

				if nx >= 0 and ny >= 0 and nx < GRID_W and ny < GRID_H:
					if grid[ny][nx] == 1:
						score += 3

	score += overlap * 20
	score -= (abs(gx - base_gx) + abs(gy - base_gy)) * 0.2

	return score
