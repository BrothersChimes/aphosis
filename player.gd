extends RigidBody2D


# Movement
const rotation_speed = 9000
const max_rotation_speed = 5.0
const max_speed = 500.0
const thrust = 12000
const forward_friction = 4.0
const sideways_friction = 120.0
const max_friction = 60000.0

const sprint_rotation_speed = 12000
const sprint_max_rotation_speed = 5.0
const sprint_max_speed = 500.0
const sprint_thrust = 60000

var current_angular_velocity: float = 0.0  # Custom angular velocity

# Trackers
var is_moving = false
var is_sprinting = false


#Oxygen System
const max_oxy = 1000
var oxy = max_oxy
var base_consumption = 0.0003
var consumption = base_consumption
var min_consumption_multiplier = 1.0
var max_consumption_multiplier = 4.0
var max_consumption = base_consumption * 3.0 * max_consumption_multiplier
var consumption_multiplier = min_consumption_multiplier

#depth system
const max_depth_possible = 8500.0
@onready var current_depth = position.y

const camera_resize_start = 5000

func get_consumption():
	var depth_ratio = (current_depth / max_depth_possible)
	consumption_multiplier = max_consumption_multiplier * depth_ratio
	print(consumption_multiplier)
	if consumption_multiplier < min_consumption_multiplier:
		consumption_multiplier = min_consumption_multiplier
	
	var new_consumption = base_consumption
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
	oxy -= oxy * consumption * delta * consumption_multiplier

func apply_depth():
	current_depth = position.y
	pass
	#current_depth = position.y

func _process(delta: float) -> void:
	apply_depth()
	consumption = get_consumption()
	suck_oxy(delta)
	sprint_bubblers()
	camera_with_depth()


func sprint_bubblers(): 
	if Input.is_action_just_pressed('sprint'):
		$Bubblegen/ManyParticles.emitting = true
		$Bubblegen/FewParticles.emitting = false
	elif Input.is_action_just_released('sprint'):
		$Bubblegen/ManyParticles.emitting = false
		$Bubblegen/FewParticles.emitting = true

@onready var camera_node = $Camera2D

func camera_with_depth(): 
	if position.y > camera_resize_start: 
		var scaling_factor = 1.0 + clampf(position.y - camera_resize_start, 0.0, 3000.0) / 1000  
		camera_node.zoom.x = 1.0 / scaling_factor
		camera_node.zoom.y = 1.0 / scaling_factor
	else: 
		camera_node.zoom.x = 1
		camera_node.zoom.y = 1	
	

func _physics_process(delta: float) -> void:

	var current_velocity = linear_velocity
	
	# Calculate the forward and sideways components of the velocity
	var forward_direction = transform.y.normalized()
	var right_direction = transform.x.normalized()
	var left_direction = -right_direction
	var forward_velocity = forward_direction * forward_direction.dot(current_velocity)
	var sideways_velocity = current_velocity - forward_velocity

	var sideways_speed_ratio = sideways_velocity.length() / max_speed  # Calculate sideways speed ratio


	# Calculate effective rotation speed based on current rotation speed
	var effective_rotation_speed
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
	elif Input.is_action_pressed('left_button'):
		apply_torque(-effective_rotation_speed * delta)
		apply_central_force(left_direction * 10000 * delta)
		is_moving = true
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
	
	# Apply forward and sideways friction
	var forward_friction_force = min(forward_friction * forward_velocity.length_squared(), max_friction) * -forward_velocity.normalized()
	var sideways_friction_force = sideways_friction * sideways_velocity.length_squared() * -sideways_velocity.normalized()
	apply_central_force((forward_friction_force + sideways_friction_force) * delta)
