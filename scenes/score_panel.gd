extends Control

@onready var score_label = $CurrentRow/HBoxContainer/CurrentLabel
@onready var best_label = $BestRow/HBoxContainer/BestLabel

var displayed_score = 0
var target_score = 0

var displayed_best = 0
var target_best = 0

var animate_best = false


func set_score(value):
	target_score = value

func set_best(value, animated := false):

	target_best = value

	if animated:
		animate_best = true
	else:
		displayed_best = value
		target_best = value
		best_label.text = str(value)

func _process(delta):

	# ===== CURRENT SCORE =====
	if displayed_score != target_score:

		var diff = target_score - displayed_score
		var step = int(max(1, abs(diff) * 0.15))

		displayed_score += sign(diff) * step

		if diff > 0:
			displayed_score = min(displayed_score, target_score)
		else:
			displayed_score = max(displayed_score, target_score)

		score_label.text = str(displayed_score)


	# ===== BEST SCORE =====
	if animate_best and displayed_best != target_best:

		var diff_b = target_best - displayed_best
		var step_b = int(max(1, abs(diff_b) * 0.15))

		displayed_best += sign(diff_b) * step_b

		if diff_b > 0:
			displayed_best = min(displayed_best, target_best)
		else:
			displayed_best = max(displayed_best, target_best)

		best_label.text = str(displayed_best)

		if displayed_best == target_best:
			animate_best = false
