extends Node2D

const PieceScene = preload("res://scenes/piece.tscn")
const Shapes = preload("res://scripts/shapes.gd")

const BASE_RESOLUTION = Vector2(1280, 720)
const PREVIEW_SCALE = 110.0 / 150.0

@onready var board_container = $".."
@onready var pieces_container = $"../../RightPanel/PiecesContainer"
@onready var right_panel = $"../../RightPanel"

var scale_factor = 1.0
var BOARD_SCALE = 0.5


func _ready():

	var screen = get_viewport_rect().size

	scale_factor = min(
		screen.x / BASE_RESOLUTION.x,
		screen.y / BASE_RESOLUTION.y
	) * BOARD_SCALE

	var board_size = BASE_RESOLUTION * scale_factor

	# масштаб тільки для поля
	board_container.scale = Vector2(scale_factor, scale_factor)

	# ❗ UI не масштабуємо
	pieces_container.scale = Vector2(1, 1)

	# позиція поля (залишаємо як було)
	board_container.position = Vector2(
		screen.x * 0.02,
		screen.y * 0.1
	)

	# ❗ контейнер не рухаємо глобально
	pieces_container.position = Vector2(0, 0)

	generate_board()
	spawn_pieces()


func spawn_pieces():

	# очистка
	for c in pieces_container.get_children():
		c.queue_free()

	var shapes_data = []

	for i in range(3):
		var shape_group = Shapes.FORMS.pick_random()
		var shape = shape_group.pick_random()
		shapes_data.append(shape)

	# === геометрія панелі ===

	var panel_width = right_panel.size.x
	var panel_height = right_panel.size.y

	var margin_x = panel_width * 0.08
	var usable_width = panel_width - margin_x * 2

	var spacing = panel_width * 0.02

	# === 🔥 РАХУЄМО ЄДИНИЙ SCALE ===

	var max_blocks = 5.0
	var total_blocks_width = 3 * max_blocks * 150.0
	var total_spacing = 2 * spacing

	var scale = (usable_width - total_spacing) / total_blocks_width

	# додатково обмежимо по висоті
	var max_height_blocks = 5.0
	var max_height = panel_height * 0.25

	var scale_h = max_height / (max_height_blocks * 150.0)

	scale = min(scale, scale_h)

	# === позиціонування ===

	var base_y = panel_height * 0.65

	var slot_width = usable_width / 3.0

	for i in range(3):

		var shape = shapes_data[i]

		var piece = PieceScene.instantiate()
		piece.setup(shape)
		piece.scale = Vector2(scale, scale)

		# === знаходимо bounds фігури ===

		var min_x = 999
		var max_x = -999
		var min_y = 999
		var max_y = -999

		for y in range(shape.size()):
			for x in range(shape[y].size()):
				if shape[y][x] == 1:
					min_x = min(min_x, x)
					max_x = max(max_x, x)
					min_y = min(min_y, y)
					max_y = max(max_y, y)

		# центр фігури в блоках
		var center_x_blocks = (min_x + max_x + 1) / 2.0
		var center_y_blocks = (min_y + max_y + 1) / 2.0

		# в пікселях
		var center_offset = Vector2(
			center_x_blocks * 150 * scale,
			center_y_blocks * 150 * scale
		)

		# центр слота
		var slot_center_x = margin_x + slot_width * (i + 0.5)
		var slot_center = Vector2(slot_center_x, base_y)

		# фінальна позиція
		piece.position = slot_center - center_offset

		pieces_container.add_child(piece)


const TileScene = preload("res://scenes/tile.tscn")

const GRID_W = 8
const GRID_H = 8
const TILE_SIZE = 150


func generate_board():
	for y in range(GRID_H):
		for x in range(GRID_W):
			var tile = TileScene.instantiate()

			# позиція в сітці
			tile.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)

			# опціонально: щоб було видно поверх всього
			tile.z_index = 1

			add_child(tile)
