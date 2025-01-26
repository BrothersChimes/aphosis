extends Node2D


signal relic_entered
signal relic_exited
@export var relic_type = 'skully'



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body):
	print('body entered')
	if body.name == "Player":
		print('player is deleting relic')
		emit_signal("relic_entered", self)
