extends Node2D

var min_value = 0.0

var max_value = 100.0

var current_value = 0.0

var current_percentage = 0.0

var target_percentage = 0.0

const ROT_MIN = deg_to_rad(112)
const ROT_MAX = deg_to_rad(428)
const SMOOTH_SPEED = 1.0


func _ready():
	pass

func _process(delta):
	move_needle(delta)
	

func set_value(new_value):
	current_value = new_value
	target_percentage = ((current_value - min_value) / (max_value - min_value) ) * 100

func set_all_values(new_current_value, new_min_value, new_max_value):
	min_value = new_min_value
	max_value = new_max_value
	set_value(current_value)


func move_needle(delta):
	var rotation_range = ROT_MAX - ROT_MIN
	current_percentage = lerp(current_percentage, target_percentage, delta * SMOOTH_SPEED)
	$Needle.rotation = ROT_MIN + ((current_percentage / 100) * rotation_range)
