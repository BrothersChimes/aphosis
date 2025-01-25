extends RigidBody2D

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
	elif Input.is_action_pressed('left_button'):
		apply_torque(-effective_rotation_speed * delta)
		apply_central_force(left_direction * 10000 * delta)
		

	if (Input.is_action_pressed('up_button')):
		var applied_thrust
		if Input.is_action_pressed('sprint'):
			var speed_ratio = current_velocity.length() / sprint_max_speed
			applied_thrust = lerp(sprint_thrust, 0, speed_ratio)  # Decrease thrust as speed approaches max_speed
		else:
			var speed_ratio = current_velocity.length() / max_speed
			applied_thrust = lerp(thrust, 0, speed_ratio)  # Decrease thrust as speed approaches max_speed
		apply_central_force(transform.y * -applied_thrust * delta)
	
	# Apply forward and sideways friction
	var forward_friction_force = min(forward_friction * forward_velocity.length_squared(), max_friction) * -forward_velocity.normalized()
	var sideways_friction_force = sideways_friction * sideways_velocity.length_squared() * -sideways_velocity.normalized()
	apply_central_force((forward_friction_force + sideways_friction_force) * delta)
