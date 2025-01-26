extends Node2D


var modulate_up = true
var time_until_modulate_down = 20.0
var show_tutorial = true
var modulation = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate = Color(1.0, 1.0, 1.0, 0.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var speed = 4 * delta
	if show_tutorial:
		if modulate_up:
			modulation += speed
			if modulation > 1.00:
				modulation = 1.00
				modulate_up = false
				time_until_modulate_down = 30.0
		else:
			time_until_modulate_down -= delta
			if time_until_modulate_down < 0.0:
				modulation -= speed / 2
				if modulation < 0.00:
					modulation = 0.00
					modulate_up = true
					show_tutorial = false
		modulate = Color(1.0, 1.0, 1.0, modulation)
	else:
		modulation -= speed / 2
		if modulation < 0.00:
			modulation = 0
		modulate = Color(1.0, 1.0, 1.0, modulation)
