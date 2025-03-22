extends CharacterBody3D

const SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5

# Sensitivity for camera rotation
var sensitivity = 0.1
var rotating = false

#Sensitivity for player rotation
var rotation_speed = 5.0

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = ($Camera_Controller.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		if Input.is_action_pressed("shift"):
			velocity.x = direction.x * SPRINT_SPEED
			velocity.z = direction.z * SPRINT_SPEED
		else:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		if Input.is_action_pressed("shift"):
			velocity.x = move_toward(velocity.x, 0, SPRINT_SPEED)
			velocity.z = move_toward(velocity.z, 0, SPRINT_SPEED)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

	# rotate character into direction is moving
	if input_dir != Vector2(0, 0):
		var target_rotation = $Camera_Controller.rotation_degrees.y - rad_to_deg(input_dir.angle()) - 90
		$MeshInstance3D.rotation_degrees.y = rad_to_deg(lerp_angle(
	deg_to_rad($MeshInstance3D.rotation_degrees.y),
	deg_to_rad(target_rotation),
	rotation_speed * delta))

	move_and_slide()
	
	# make camera controller match the position of player
	$Camera_Controller.position = lerp($Camera_Controller.position, position, 0.08)

func _input(event):
	# Detect right mouse button press/release
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			rotating = event.pressed

	# Detect mouse motion and rotate if right button is pressed
	if rotating and event is InputEventMouseMotion:
		# Apply rotation based on mouse motion
		#$Camera_Controller.rotate_x(deg_to_rad(-event.relative.y * sensitivity))  # Vertical rotation
		$Camera_Controller.rotate_y(deg_to_rad(-event.relative.x * sensitivity))  # Horizontal rotation
