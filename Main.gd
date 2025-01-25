extends Node2D

@onready var player = $Player
@onready var HUD = $HUD

var o2 = 1000.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$HUD/GuageO2.set_all_values(o2, 0.0, player.max_oxy)
	$HUD/GuageConsumption.set_all_values(o2, 0.0, player.max_consumption)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$HUD/GuageO2.set_value(player.get_oxy())
	$HUD/GuageConsumption.set_value(player.consumption)
	pass
	#$Camera2D.rotation += delta / 5
