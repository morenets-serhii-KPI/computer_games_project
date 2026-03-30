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

func play_clear_animation():

	var t = create_tween()
	t.set_parallel(true)

	# 1. імпульс (вибух назовні)
	t.tween_property(self, "scale", Vector2(1.3, 1.3), 0.08)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# 2. легкий відскок назад
	t.tween_property(self, "scale", Vector2(0.9, 0.9), 0.06)\
		.set_delay(0.08)

	# 3. зникнення
	t.tween_property(self, "scale", Vector2(0.0, 0.0), 0.12)\
		.set_delay(0.12)

	t.tween_property(self, "modulate:a", 0.0, 0.12)\
		.set_delay(0.12)

	# 4. невеликий підліт
	t.tween_property(self, "position:y", position.y - 15, 0.12)\
		.set_delay(0.12)

	# 5. випадковий поворот (дає “хаос”)
	rotation_degrees = randf_range(-10, 10)
	t.tween_property(self, "rotation_degrees", randf_range(-45, 45), 0.15)

	await t.finished

	# reset
	scale = Vector2.ONE
	modulate.a = 1.0
	rotation_degrees = 0
	position.y += 15

	set_filled(false)

	# частинки
	_spawn_particles()


func _spawn_particles():

	var p = GPUParticles2D.new()
	add_child(p)

	p.amount = 12
	p.lifetime = 0.4
	p.one_shot = true
	p.explosiveness = 1.0
	p.speed_scale = 1.5

	var mat = ParticleProcessMaterial.new()
	p.process_material = mat

	mat.direction = Vector3(0, -1, 0)
	mat.spread = 180
	mat.gravity = Vector3(0, 300, 0)

	mat.initial_velocity_min = 120
	mat.initial_velocity_max = 220

	mat.scale_min = 0.2
	mat.scale_max = 0.4

	mat.color = Color(1, 1, 1, 0.9)

	p.emitting = true

	await get_tree().create_timer(0.5).timeout
	p.queue_free()
