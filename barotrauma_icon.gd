extends Node2D

const MIN_BAROTRAUMA_LEVEL = 1
const MAX_BAROTRAUMA_LEVEL = 5
@onready var is_barotraumatic = false
var modulation = 0.00
var modulate_up = true
var barotrauma_level = 1
var pump_count = 0
var time_until_modulate_down = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	alternate_modulate(delta)
	pass

func set_no_barotrauma():
	is_barotraumatic = false

func set_barotrauma_level_to(level):
	is_barotraumatic = true
	barotrauma_level = clamp(level, MIN_BAROTRAUMA_LEVEL, MAX_BAROTRAUMA_LEVEL)

func alternate_modulate(delta):
	var speed = delta * barotrauma_level
	if is_barotraumatic:
		if modulate_up:
			modulation += speed
			if modulation > 1.00:
				modulation = 1.00
				modulate_up = false
				time_until_modulate_down = 2.0 / barotrauma_level
		else:
			time_until_modulate_down -= delta
			if time_until_modulate_down < 0.0:
				modulation -= speed / 2
				if modulation < 0.00:
					modulation = 0.00
					modulate_up = true
					if barotrauma_level <= 2:
						$Subtitle.text = "[center]DECOMPRESS D[/center]"
					elif barotrauma_level <= 5:
						$Subtitle.text = "[center]DEATH IMMENENT[/center]"
					else:
						$Subtitle.text = "[center]DIVE NOW[/center]"
		modulate = Color(1.0, 1.0, 1.0, modulation)
	else:
		modulation -= speed / 2
		if modulation < 0.00:
			modulation = 0
		modulate = Color(1.0, 1.0, 1.0, modulation)
