extends Node2D

@onready var player = $Player
@onready var HUD = $HUD

var o2 = 1000.0

func _ready():
	$HUD/GuageO2.set_all_values(o2, 0.0, player.max_oxy)
	$HUD/GuageConsumption.set_all_values(o2, 0.0, player.max_consumption)
	$HUD/GuageDepth.set_all_values(player.get_depth(), 0.0, player.max_depth_possible)


func _process(delta):
	$HUD/GuageO2.set_value(player.get_oxy())
	$HUD/GuageConsumption.set_value(player.get_consumption())
	$HUD/GuageDepth.set_value(player.get_depth())
