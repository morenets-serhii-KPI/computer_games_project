extends Node2D

var form = []

const TILE_SIZE = 150
var block_scene = preload("res://scenes/piece_block.tscn")


func setup(shape):

	form = shape

	clear_blocks()
	create_blocks()


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
