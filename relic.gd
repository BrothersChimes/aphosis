extends Node2D


signal relic_entered(relic)
@export var relic_type = 'skully'



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

var is_despawning = false
var modulation = 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_despawning:
		modulation -= delta
		if modulation < 0:
			queue_free()
			return
		modulate = Color(1.0, 1.0, 1.0, modulation)
		

func _on_area_2d_body_entered(body):
	print('body entered')
	if body.name == "Player":
		print('player is deleting relic')
		emit_signal("relic_entered", self)

func despawn():
	is_despawning = true
