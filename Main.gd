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

var has_madskull = false;
var has_numbskull = false;
var has_anti = false
func _on_relic_entered(relic):
	print("got ", relic.relic_type)
	if relic.relic_type == "madskull" and not has_madskull:
		has_madskull = true
		print('player is getting skull')
		show_relic_text("RELIC FOUND", "Ancient Skull of a Giant", "Doubles your max oxygen", "A skull so large and neutrally boyuant serves as an excellent diving bell.")
		player.max_oxy *= 2 
		$HUD/GuageO2.set_all_values(player.get_oxy(), 0.0, player.max_oxy)
	if relic.relic_type == "numbskull" and not has_numbskull:
		has_numbskull = true
		print('player is getting skull')
		show_relic_text("RELIC FOUND", "Horrifically Deformed Giant Skull", "Reduces Barotrauma", "Nothing could break free from a skull so thick! Not even ideas.")
		player.has_numbskull = true
	if relic.relic_type == "anti" and not has_anti:
		has_anti = true
		show_relic_text("RELIC FOUND", "Antikythera", "Increases Movement Speed", "A curious artifact, an antiquated diving helm in a much larger size.")
		player.thrust += 2500
		player.max_speed += 100
		player.sprint_thrust += 25000
		player.sprint_max_speed += 100
	if relic.relic_type == "deaddiver":
		show_relic_text("FELLOW DIVER FOUND", "Robert Parr", "A sad state of affairs", "In his final moments, running out of O2, he chose to dive deeper and make one last discovery...")
		
		 
	relic.despawn()
	is_showing_relic = true
	time_until_modulate_down = 20

func show_relic_text(relic_unlocked, title, effect, flavour_text):
	$HUD/RelicText/Title1.text = "[center]" + str(relic_unlocked) + "[/center]"
	$HUD/RelicText/Title1.visible = true
	$HUD/RelicText/Subtitle1.text = "[center]" + str(effect) + "[/center]"
	$HUD/RelicText/Subtitle1.visible = true
	$HUD/RelicText/Title2.text = "[center]" + str(title) + "[/center]"
	$HUD/RelicText/Title2.visible = true
	$HUD/RelicText/Subtitle2.text = "[center]" + '"' + str(flavour_text) + '"' + "[/center]"
	$HUD/RelicText/Subtitle2.visible = true


func _on_tutorial_bounds_entered(body):
	print('tut bound entered')
	if body.name == "Player":
		$HUD/TutorialText.show_tutorial = false

