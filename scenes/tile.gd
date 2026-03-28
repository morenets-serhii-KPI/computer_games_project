extends Node2D

@onready var cell = $Cell
@onready var block = $Block

func _ready():
	block.visible = false

func set_filled(value):

	if value:
		block.visible = true
	else:
		block.visible = false
