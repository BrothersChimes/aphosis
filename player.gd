extends RigidBody2D

var has_numbskull = false

@onready var is_dead = false
# Movement
const rotation_speed = 9000
const max_rotation_speed = 5.0
var max_speed = 500.0
var thrust = 12000
const forward_friction = 4.0
const sideways_friction = 120.0
const max_friction = 60000.0

const sprint_rotation_speed = 12000
const sprint_max_rotation_speed = 5.0
var sprint_max_speed = 500.0
var sprint_thrust = 60000


var current_angular_velocity: float = 0.0  # Custom angular velocity

# Trackers
var is_moving = false
var is_sprinting = false


#Oxygen System
var max_oxy = 1000
var oxy = max_oxy
var base_consumption = 0.03
var consumption = base_consumption
var min_consumption_multiplier = 1.0
var max_consumption_multiplier = 4.0
var max_consumption = base_consumption * 3.0 * max_consumption_multiplier
var consumption_multiplier = min_consumption_multiplier

#depth system
const max_depth_possible = 8500.0
@onready var current_depth = position.y

#barotrauma system
@onready var is_decompressing = false
@onready var current_pressure = current_depth
@onready var current_barotrauma = 1
@onready var is_barotraumatic = 0
const PRESSURE_STACK_RAMP_UP = 0.005
const PRESSURE_STACK_RAMP_DOWN = 0.05

#flip movement system
var is_flipping = false
var flip = false
var flip_timer = 0.0
const flip_time = 1.2

const camera_resize_start = 5000

var breath_timer = 3.0
var breathe_out = true

@onready var redhaze = $Redhaze
const max_health = 100.0
var health = max_health

@onready var hasnt_died_yet = true
@onready var has_finished_dying = false

@onready var camera_node = get_parent().get_node("Camera2D")

func get_consumption():
	var depth_ratio = (current_depth / max_depth_possible)
	consumption_multiplier = max_consumption_multiplier * depth_ratio
	if consumption_multiplier < min_consumption_multiplier:
		consumption_multiplier = min_consumption_multiplier
	
	var new_consumption = base_consumption
	if is_decompressing:
		new_consumption += base_consumption
		new_consumption += base_consumption
		new_consumption += base_consumption
		new_consumption += base_consumption
		new_consumption += base_consumption
	if is_moving:
		new_consumption += base_consumption
		if is_sprinting:
			new_consumption += base_consumption
	return new_consumption * consumption_multiplier

func get_oxy():
	return oxy

func get_depth():
	return current_depth

func suck_oxy(delta):
	if position.y <= 5:
		oxy = max_oxy
	oxy -= consumption * delta * consumption_multiplier * 10
	if oxy <= 0:
		is_dead = true

func apply_depth():
	current_depth = position.y
	pass
	#current_depth = position.y

func get_pressure():
	return current_pressure

func set_barotrauma_level(level):
	current_barotrauma = clamp (level, 1, 5)
	is_barotraumatic = true

func get_barotrauma_level():
	return current_barotrauma

func set_no_barotrauma():
	is_barotraumatic = false

var pressure_diff = 0
var current_mod = 0.0

func apply_pressure_stacks(delta):
	if Input.is_action_pressed('decompress') and current_barotrauma < 3:
		is_decompressing = true
	else:
		is_decompressing = false
		
	# current pressure approaches current depth
	if current_pressure > current_depth:
		if is_decompressing:
			current_pressure = lerp(current_pressure, get_depth(), delta * PRESSURE_STACK_RAMP_DOWN * 10)
		else:
			current_pressure = lerp(current_pressure, get_depth(), delta * PRESSURE_STACK_RAMP_DOWN)
	else:
		current_pressure = lerp(current_pressure, get_depth(), delta * PRESSURE_STACK_RAMP_UP)
	
		
	pressure_diff = current_pressure - current_depth
	var npd = 0
	if has_numbskull:
		npd = 400
	
	if pressure_diff > 1000 + npd:
		is_dead = true
		# print('dead')
	elif pressure_diff > 900 + npd:
		# print('over 900')
		set_barotrauma_level(5)
	elif pressure_diff > 800 + npd:
		set_barotrauma_level(4)
	elif pressure_diff > 700 + npd:
		set_barotrauma_level(3)
	elif pressure_diff > 600 + npd:
		set_barotrauma_level(2)
	elif pressure_diff > 500 + npd:
		set_barotrauma_level(1)
	else:
		set_no_barotrauma()
	
	# print('isdead: ' + str(is_dead))

	if is_barotraumatic:
		# print("BT: " + str(int(get_barotrauma_level())) + ",     depth: " + str(int(get_depth())) + ',    press: ' + str(int(current_pressure)) + ',     pdiff: ' + str(int(pressure_diff)))
		var barosquared = (get_barotrauma_level() - 1) * (get_barotrauma_level() - 1)
		health -= barosquared * delta
	if !is_barotraumatic: 
		# print('nbt: depth: ' + str(int(get_depth())) + ',    press: ' + str(int(current_pressure)) + ',     pdiff: ' + str(int(pressure_diff)))

		health = clampf(health + 2*delta, 0, max_health)
	# print("health: " + str(health))
		
	var hpmodulation = 1.0 -  health / max_health
	var baromod = (get_barotrauma_level() - 1.0) / 4.0
	var mod = max(hpmodulation, baromod)
	current_mod = lerpf(current_mod, mod, 0.01)
	
	redhaze.modulate = Color(1,1,1, current_mod * 0.6)
	
	
	
	var haze_scale = clampf(8.0 * health/max_health, 2.0, 8.0) 
	
	var base_zoom = 1.2
	var scaling_factor = base_zoom + 7.0*pow(current_mod, 2.5)  
	scaling_factor = clampf(scaling_factor, base_zoom, 4.0)
	# print(scaling_factor)
	camera_node.zoom.x = base_zoom * scaling_factor
	camera_node.zoom.y = base_zoom * scaling_factor
	
	#if get_barotrauma_level() == 5: 
		#haze_scale = 2.0

	redhaze.scale.x = haze_scale
	redhaze.scale.y = haze_scale

	if health <= 0: 
		is_dead = true
		# print('dead')

func _ready():
	$DiverSprite.connect("frame_changed", self._on_frame_changed)

func _on_frame_changed():
	if is_dead && not has_finished_dying:
		if $DiverSprite.frame == $DiverSprite.sprite_frames.get_frame_count("death") - 1:
			$DiverSprite.stop()
			has_finished_dying = true
			$DiverSprite.set_frame_and_progress($DiverSprite.sprite_frames.get_frame_count("death") - 1, 0.0)


func _process(delta: float) -> void:
	if Input.is_action_pressed('pressurize'):
		current_pressure = current_depth
	# print("POSITION: " + str(int(position.y)))
	$LabelNode/Label.text = "pdiff: " + str(int(pressure_diff)) + " hp: " + str(int(health))

	if is_dead && hasnt_died_yet:
		$Bubblegen/ManyParticles.emitting = true
		$Bubblegen/FewParticles.emitting = true
		hasnt_died_yet = false
		$DiverSprite.animation = "death"
		$DiverSprite.set_frame_and_progress(0, 0.0)
	if is_dead && not hasnt_died_yet:
		$Bubblegen/ManyParticles.emitting = false
		$Bubblegen/FewParticles.emitting = false
		
	apply_depth()
	apply_pressure_stacks(delta)
	consumption = get_consumption()
	suck_oxy(delta)
	sprint_bubblers(delta)
	#camera_with_depth()
	play_music()
	rotate_camera(delta)

enum CameraMode { 
	STATIC,
	DIRECT,
	DELAYED,
	DEPTH_DELAYED,
}	

var camera_mode = CameraMode.DEPTH_DELAYED

func rotate_camera(delta): 
	camera_node.position = position
	match camera_mode:
		CameraMode.STATIC:
			pass
		CameraMode.DIRECT:
			camera_node.rotation = rotation + deg_to_rad(-90)
		CameraMode.DELAYED:
			camera_node.rotation = lerp_angle(camera_node.rotation, rotation + deg_to_rad(-90), delta*0.5)
		CameraMode.DEPTH_DELAYED:
			var depth = get_depth()
			# var rotator = clamp(depth - 1000, 0,10000)
			if depth >= 1200:
				camera_node.rotation = lerp_angle(camera_node.rotation, rotation + deg_to_rad(-90), delta*0.5)
			if depth >= 2000: 
				camera_mode = CameraMode.DIRECT

			
@onready var music_player = $BasicMusicPlayer
@onready var deep_music_player = $DeepMusicPlayer

var is_playing_music = false
var is_playing_deep_music = false

func play_music(): 
	if !is_playing_music: 
		if get_depth() > 1450: 
			music_player.play()
			is_playing_music = true
	if !is_playing_deep_music: 
		if get_depth() > 5925: 
			music_player.stop()
			is_playing_deep_music = true
			deep_music_player.play()
	elif is_playing_deep_music and get_depth() < 5000: 
			deep_music_player.stop()
			is_playing_deep_music = false
			is_playing_music = true
			music_player.play()
		
func sprint_bubblers(delta): 
	if is_dead:
		$Bubblegen/ManyParticles.emitting = false
		$Bubblegen/FewParticles.emitting = false
		return
	if Input.is_action_pressed('sprint'):
		breath_timer -= 1.5*delta
	else: 
		breath_timer -= delta
		
	if breath_timer <= 0:
		if breathe_out:
			if Input.is_action_pressed('sprint'):
				$Bubblegen/ManyParticles.emitting = true
			else: 
				$Bubblegen/FewParticles.emitting = true
		else: 
			$Bubblegen/ManyParticles.emitting = false
			$Bubblegen/FewParticles.emitting = false

		
		breathe_out = !breathe_out
		breath_timer = 3.0
	
func camera_with_depth(): 
	if position.y > camera_resize_start: 
		var scaling_factor = 1.0 + clampf(position.y - camera_resize_start, 0.0, 3000.0) / 1000  
		camera_node.zoom.x = 1.0 / scaling_factor
		camera_node.zoom.y = 1.0 / scaling_factor
	else:
		camera_node.zoom.x = 1
		camera_node.zoom.y = 1	
	

func _physics_process(delta: float) -> void:
	if is_dead:
		linear_damp = 10.0
		return

	var current_velocity = linear_velocity
	
	# Calculate the forward and sideways components of the velocity
	var forward_direction = transform.y.normalized()
	var right_direction = transform.x.normalized()
	var left_direction = -right_direction
	var forward_velocity = forward_direction * forward_direction.dot(current_velocity)
	var sideways_velocity = current_velocity - forward_velocity

	var sideways_speed_ratio = sideways_velocity.length() / max_speed  # Calculate sideways speed ratio

	if is_decompressing:
		var forward_friction_force = min(forward_friction * forward_velocity.length_squared(), max_friction) * -forward_velocity.normalized()
		var sideways_friction_force = sideways_friction * sideways_velocity.length_squared() * -sideways_velocity.normalized()
		apply_central_force((forward_friction_force + sideways_friction_force) * delta)
		return
		
	var effective_rotation_speed
	if Input.is_action_pressed('flip'):
		if not is_flipping:
			flip_timer = 0.0
		is_flipping = true
	if is_flipping:
		if flip_timer < flip_time:
			is_sprinting = true
			var rotation_speed_ratio = abs(current_angular_velocity) / (sprint_max_rotation_speed * 10)
			effective_rotation_speed = lerp(sprint_rotation_speed, 0, rotation_speed_ratio)
			apply_torque(-effective_rotation_speed * delta * 6)
		else:
			is_sprinting = false
			is_flipping = false
		flip_timer += delta


	# Calculate effective rotation speed based on current rotation speed
	if Input.is_action_pressed('sprint'):
		var rotation_speed_ratio = abs(current_angular_velocity) / sprint_max_rotation_speed
		effective_rotation_speed = lerp(sprint_rotation_speed, 0, rotation_speed_ratio)
	else:
		var rotation_speed_ratio = abs(current_angular_velocity) / max_rotation_speed
		effective_rotation_speed = lerp(rotation_speed, 0, rotation_speed_ratio)


	if Input.is_action_pressed('right_button'):
		apply_torque(effective_rotation_speed * delta)
		apply_central_force(right_direction * 10000 * delta)
		is_moving = true
		if Input.is_action_pressed('sprint') and not (Input.is_action_pressed('up_button') or  Input.is_action_pressed('up_button')):
			is_sprinting = true
			apply_torque(effective_rotation_speed * delta)
			apply_torque(effective_rotation_speed * delta)
	elif Input.is_action_pressed('left_button'):
		apply_torque(-effective_rotation_speed * delta)
		apply_central_force(left_direction * 10000 * delta)
		is_moving = true
		if Input.is_action_pressed('sprint') and not (Input.is_action_pressed('up_button') or  Input.is_action_pressed('up_button')):
			is_sprinting = true
			apply_torque(-effective_rotation_speed * delta)
			apply_torque(-effective_rotation_speed * delta)
	else: is_moving = false
		

	if (Input.is_action_pressed('up_button')):
		is_moving = true
		var applied_thrust
		if Input.is_action_pressed('sprint'):
			var speed_ratio = current_velocity.length() / sprint_max_speed
			applied_thrust = lerp(sprint_thrust, 0, speed_ratio)  # Decrease thrust as speed approaches max_speed
			is_sprinting = true
		else:
			var speed_ratio = current_velocity.length() / max_speed
			applied_thrust = lerp(thrust, 0, speed_ratio)  # Decrease thrust as speed approaches max_speed
			is_sprinting = false
		apply_central_force(transform.y * -applied_thrust * delta)
	if (Input.is_action_pressed('down_button')):
		is_moving = true
		var applied_thrust
		var speed_ratio = current_velocity.length() / max_speed
		applied_thrust = lerp(thrust, 0, speed_ratio) / 4
		is_sprinting = false
		apply_central_force(transform.y * applied_thrust * delta)
	
	# Apply forward and sideways friction
	var forward_friction_force = min(forward_friction * forward_velocity.length_squared(), max_friction) * -forward_velocity.normalized()
	var sideways_friction_force = sideways_friction * sideways_velocity.length_squared() * -sideways_velocity.normalized()
	apply_central_force((forward_friction_force + sideways_friction_force) * delta)
