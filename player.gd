extends RigidBody2D

const rotation_speed = 9000
const max_rotation_speed = 5.0
const max_speed = 240.0
const thrust = 12000
const forward_friction = 6.0
const sideways_friction = 120.0
const max_friction = 60000.0

var current_angular_velocity: float = 0.0  # Custom angular velocity

func _physics_process(delta: float) -> void:

	var current_velocity = linear_velocity
	
	# Calculate the forward and sideways components of the velocity
	var forward_direction = transform.y.normalized()
	var forward_velocity = forward_direction * forward_direction.dot(current_velocity)
	var sideways_velocity = current_velocity - forward_velocity

	var sideways_speed_ratio = sideways_velocity.length() / max_speed  # Calculate sideways speed ratio

	var rotation_speed_ratio = abs(current_angular_velocity) / max_rotation_speed

	# Calculate effective rotation speed based on current rotation speed
	var effective_rotation_speed = lerp(rotation_speed, 0, rotation_speed_ratio)

	if Input.is_action_pressed('right_button'):
		apply_torque(effective_rotation_speed * delta)
	elif Input.is_action_pressed('left_button'):
		apply_torque(-effective_rotation_speed * delta)
		

	if (Input.is_action_pressed('up_button')):
		var speed_ratio = current_velocity.length() / max_speed
		var applied_thrust = lerp(thrust, 0, speed_ratio)  # Decrease thrust as speed approaches max_speed
		apply_central_force(transform.y * -applied_thrust * delta)
	
	# Apply forward and sideways friction
	var forward_friction_force = min(forward_friction * forward_velocity.length_squared(), max_friction) * -forward_velocity.normalized()
	var sideways_friction_force = sideways_friction * sideways_velocity.length_squared() * -sideways_velocity.normalized()
	apply_central_force((forward_friction_force + sideways_friction_force) * delta)
