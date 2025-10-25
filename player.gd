extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.8
const SENSITIVITY = 0.004

# Bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

# FOV variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Gravity
var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D

# Reference to the barricade template node already in the scene
@onready var barricade_template = get_tree().root.get_node("Game/3d-models/Sandbag") # <-- adjust path to your in-scene template


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

	# Debug key: spawn barricade
	if event is InputEventKey and event.pressed and event.keycode == Key.KEY_H:
		_spawn_barricade()


func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Sprint
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Movement
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV adjustment
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func _spawn_barricade():
	if barricade_template == null:
		print("Barricade template not found!")
		return
	
	# Duplicate the template node (deep copy)
	var barricade_instance = barricade_template.duplicate()
	barricade_instance.name = "BarricadeInstance"

	# Forward direction from the camera
	var forward = -camera.global_transform.basis.z.normalized()
	
	# Spawn 3 units in front of player
	var spawn_position = global_transform.origin + forward * 3.0
	barricade_instance.global_transform.origin = spawn_position
	
	# Match rotation to player's POV (camera yaw only)
	var rotation_y = camera.global_transform.basis.get_euler().y
	barricade_instance.rotation = Vector3(0, rotation_y, 0)
	
	# Assign collision layer 1 to all PhysicsBody3D inside the barricade
	_set_collision_layer_recursive(barricade_instance, 1)
	
	# Add to current scene
	get_tree().current_scene.add_child(barricade_instance)
	print("Barricade cloned and placed with player-facing rotation on collision layer 1!")


# Recursive helper to assign collision layer
func _set_collision_layer_recursive(node: Node, layer: int):
	if node is PhysicsBody3D:
		node.collision_layer = layer
	for child in node.get_children():
		_set_collision_layer_recursive(child, layer)
