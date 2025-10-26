extends CharacterBody3D

# === Movement constants ===
var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.8
const SENSITIVITY = 0.004

# === Head bob constants ===
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

# === FOV constants ===
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# === Gravity ===
var gravity = 9.8

# === Player stats ===
@export var health: int = 70
@export var max_health: int = 100

# === Hotbar constants ===
const HOTBAR_SIZE = 5
var hotbar_items: Array = []
var current_hotbar_index := 0
var equipped_item: Node = null

# === Node references ===
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var hotbar_storage = $HotbarStorage

# Reference to templates
@onready var barricade_template = get_tree().root.get_node("Game/3d-models/Sandbag") # adjust path
@onready var zombie_template = get_tree().root.get_node("Game/Zombie") # adjust path
@onready var shotgun_template = get_tree().root.get_node("Game/3d-models/Shotgun") # adjust path

# === Damage flash overlay ===
@onready var damage_flash_layer: CanvasLayer = CanvasLayer.new()
@onready var damage_flash_rect: ColorRect = ColorRect.new()
@export var flash_duration: float = 0.2

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Initialize hotbar with empty slots
	hotbar_items.resize(HOTBAR_SIZE)
	for i in range(HOTBAR_SIZE):
		hotbar_items[i] = null

	# Initialize damage flash overlay
	_init_damage_flash()

	# Give player a shotgun in slot 1
	if shotgun_template:
		add_item_to_hotbar(shotgun_template.duplicate())
		_select_hotbar_item(0)

func _init_damage_flash():
	add_child(damage_flash_layer)
	damage_flash_layer.layer = 100
	damage_flash_rect.color = Color(1,0,0,0)
	damage_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	damage_flash_layer.add_child(damage_flash_rect)
	damage_flash_rect.anchors_preset = Control.PRESET_FULL_RECT

func take_damage(amount: int) -> void:
	health -= amount
	health = max(health, 0)
	print("💔 Player took", amount, "damage! HP:", health)
	_trigger_damage_flash()
	if health <= 0:
		print("☠️ Player is dead!")

func _trigger_damage_flash():
	damage_flash_rect.color = Color(1, 0, 0, 0.5)
	var tween = create_tween()
	tween.tween_property(damage_flash_rect, "color", Color(1, 0, 0, 0), flash_duration)

func _unhandled_input(event):
	# Camera rotation
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

	# Debug: spawn barricade
	if event is InputEventKey and event.pressed and event.keycode == Key.KEY_H:
		_spawn_barricade()

	# Debug: spawn zombie
	if event is InputEventKey and event.pressed and event.keycode == Key.KEY_J:
		_spawn_zombie()

	# Hotbar slot selection (keys 1–5)
	if event is InputEventKey and event.pressed:
		var key_num = event.keycode - Key.KEY_1
		if key_num >= 0 and key_num < HOTBAR_SIZE:
			_select_hotbar_item(key_num)

	# Use equipped item (LMB)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if equipped_item and equipped_item.has_method("use_item"):
			equipped_item.use_item()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED

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
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

# === Barricade spawn ===
func _spawn_barricade():
	if barricade_template == null:
		print("Barricade template not found!")
		return
	
	var barricade_instance = barricade_template.duplicate()
	barricade_instance.name = "BarricadeInstance"

	var forward = -camera.global_transform.basis.z.normalized()
	var spawn_position = global_transform.origin + forward * 3.0
	barricade_instance.global_transform.origin = spawn_position

	var rotation_y = camera.global_transform.basis.get_euler().y
	barricade_instance.rotation = Vector3(0, rotation_y, 0)

	_set_collision_layer_recursive(barricade_instance, 1)
	get_tree().current_scene.add_child(barricade_instance)
	print("Barricade cloned and placed!")

	add_item_to_hotbar(barricade_instance)

# === Zombie spawn ===
func _spawn_zombie():
	if zombie_template == null:
		print("Zombie template not found!")
		return
	
	var zombie_instance = zombie_template.duplicate()
	zombie_instance.name = "ZombieInstance"

	var forward = -camera.global_transform.basis.z.normalized()
	var spawn_position = global_transform.origin + forward * 5.0
	zombie_instance.global_transform.origin = spawn_position

	zombie_instance.rotation.y = rotation.y

	get_tree().current_scene.add_child(zombie_instance)
	print("🧟 Spawned a zombie at", spawn_position)

# === Hotbar system ===
func add_item_to_hotbar(item_source: Node) -> bool:
	for i in range(HOTBAR_SIZE):
		if hotbar_items[i] == null:
			hotbar_items[i] = item_source
			if item_source.get_parent():
				item_source.get_parent().remove_child(item_source)
			hotbar_storage.add_child(item_source)
			item_source.visible = false
			return true
	return false

func _select_hotbar_item(index: int):
	current_hotbar_index = index

	if equipped_item:
		equipped_item.visible = false
		equipped_item.get_parent().remove_child(equipped_item)
		hotbar_storage.add_child(equipped_item)
		_enable_collisions_recursive(equipped_item)
		equipped_item = null

	var item = hotbar_items[index]
	if item == null:
		return

	if item.get_parent():
		item.get_parent().remove_child(item)
	camera.add_child(item)
	item.visible = true
	equipped_item = item

	item.position = item.get("hand_position")
	item.rotation_degrees = item.get("hand_rotation_degrees")
	item.scale = item.get("hand_scale")

	_disable_collisions_recursive(item)

func _disable_collisions_recursive(node: Node) -> void:
	if node is CollisionShape3D:
		node.disabled = true
	for child in node.get_children():
		_disable_collisions_recursive(child)

func _enable_collisions_recursive(node: Node) -> void:
	if node is CollisionShape3D:
		node.disabled = false
	for child in node.get_children():
		_enable_collisions_recursive(child)

func _set_collision_layer_recursive(node: Node, layer: int):
	if node is PhysicsBody3D:
		node.collision_layer = layer
	for child in node.get_children():
		_set_collision_layer_recursive(child, layer)
