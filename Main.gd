extends Node2D

@onready var player = $Player
@onready var HUD = $HUD

var o2 = 1000.0

func _ready():
	$HUD/GuageO2.set_all_values(o2, 0.0, player.max_oxy)
	$HUD/GuageConsumption.set_all_values(o2, 0.0, player.max_consumption)
	$HUD/GuageDepth.set_all_values(player.get_depth(), 0.0, player.max_depth_possible)


var modulate_up = true
var time_until_modulate_down = 20.0
var is_showing_relic = false
var modulation = 0.0
func _process(delta):
	# print("playerdead? " + str(player.is_dead) + "   y: " +  str(int(player.position.y)) )
	if player.is_dead:
		$HUD/BarotraumaIcon/Subtitle.text = "[center]DEAD[/center]"
		return
	$HUD/GuageO2.set_value(player.get_oxy())
	$HUD/GuageConsumption.set_value(player.get_consumption())
	$HUD/GuageDepth.set_value(player.get_depth())
	if player.is_barotraumatic:
		$HUD/BarotraumaIcon.set_barotrauma_level_to(player.get_barotrauma_level())
	else:
		$HUD/BarotraumaIcon.set_no_barotrauma()
	var speed = delta * 4
	if is_showing_relic:
		if modulate_up:
			modulation += speed
			if modulation > 1.00:
				modulation = 1.00
				modulate_up = false
				time_until_modulate_down = 20.0
		else:
			time_until_modulate_down -= delta
			if time_until_modulate_down < 0.0:
				modulation -= speed / 2
				if modulation < 0.00:
					modulation = 0.00
					modulate_up = true
					is_showing_relic = false
		$HUD/RelicText.modulate = Color(1.0, 1.0, 1.0, modulation)
	else:
		modulation -= speed / 2
		if modulation < 0.00:
			modulation = 0
		$HUD/RelicText.modulate = Color(1.0, 1.0, 1.0, modulation)

var has_skull = false;
func _on_relic_entered(relic):
	print("got ", relic.relic_type)
	if relic.relic_type == "skull" and not has_skull:
		has_skull = true
		print('player is getting skull')
		show_relic_text("Ancient Skull of a Giant", "Doubles your max oxygen", "A skull so large and neutrally boyuant serves as an excellent diving bell.")
		player.max_oxy *= 2 
		$HUD/GuageO2.set_all_values(player.get_oxy(), 0.0, player.max_oxy)
	relic.despawn()
	is_showing_relic = true
	time_until_modulate_down = 20

func show_relic_text(title, effect, flavour_text):
	$HUD/RelicText/Title1.text = "[center]RELIC UNLOCKED[/center]"
	$HUD/RelicText/Title1.visible = true
	$HUD/RelicText/Subtitle1.text = "[center]" + str(effect) + "[/center]"
	$HUD/RelicText/Subtitle1.visible = true
	$HUD/RelicText/Title2.text = "[center]" + str(title) + "[/center]"
	$HUD/RelicText/Title2.visible = true
	$HUD/RelicText/Subtitle2.text = "[center]" + '"' + str(flavour_text) + '"' + "[/center]"
	$HUD/RelicText/Subtitle2.visible = true


