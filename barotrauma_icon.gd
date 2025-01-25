extends Node2D

const MIN_BAROTRAUMA_LEVEL = 1
const MAX_BAROTRAUMA_LEVEL = 4
var is_barotraumatic = true
var modulation = 0.00
var modulate_up = true
var barotrauma_level = 4.0
var pump_count = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	alternate_modulate(delta)
	pass

func set_barotrauma_level(level):
	barotrauma_level = clamp(level, MIN_BAROTRAUMA_LEVEL, MAX_BAROTRAUMA_LEVEL)


func alternate_modulate(delta):
	if is_barotraumatic:
		
		var speed = delta * barotrauma_level
		if modulate_up:
			modulation += speed
			if modulation > 1.00:
				modulation = 1.00
				modulate_up = false
		else:
			modulation -= speed
			if modulation < 0.00:
				modulation = 0.00
				modulate_up = true
		modulate = Color(1.0, 1.0, 1.0, modulation)
	else:
		modulate = Color(1.0, 1.0, 1.0, 0.0)
