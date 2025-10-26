extends Node3D

# --- Hand offset when equipped ---
@export var hand_position: Vector3 = Vector3(0.7, -0.4, -0.8)
@export var hand_rotation_degrees: Vector3 = Vector3(0, 0, 0)
@export var hand_scale: Vector3 = Vector3(0.1, 0.1, 0.1)

# --- Placement & pickup ---
@export var place_distance: float = 3.0
@export var pickup_distance: float = 3.0
@export var item_name: String = "Barricade"

# --- Barricade health ---
@export var max_health: int = 100
var health: int = max_health

# --- Spin & Float settings ---
@export var spin_speed: float = 45.0          # degrees per second
@export var float_amplitude: float = 0.2      # vertical bobbing range
@export var float_speed: float = 2.5          # how fast it moves up/down
var _base_y: float = 0.0
var _time: float = 0.0

# --- Scale settings ---
@export var world_scale_factor: float = 0.25  # 75% when pickup-able
var _original_scale: Vector3

# --- State ---
var picked_up: bool = false
var placed: bool = false
var player: Node = null

# --- References ---
@onready var mesh: MeshInstance3D = $MeshInstance3D if has_node("MeshInstance3D") else null
@onready var collider: StaticBody3D = $StaticBody3D if has_node("StaticBody3D") else null

# --- Icon placeholder (replace with your own texture later) ---
@export var icon_texture: Texture2D = preload("res://images/bagg008_1.webp")

func _ready():
	# Safely find player anywhere in the scene tree
	player = get_tree().get_root().find_child("Player", true, false)
	if not player:
		push_warning("⚠️ Barricade: Player node not found in scene tree!")
	else:
		print("✅ Barricade linked to player:", player.name)

	# Set metadata for hotbar icon
	set_meta("icon", icon_texture)

	add_to_group("barricades")
	_base_y = global_position.y
	_original_scale = scale

	# Apply smaller scale only if it's a pickup-able world object
	if not placed and not picked_up:
		scale = _original_scale * world_scale_factor

	set_process(true)


func _process(delta):
	# Skip animation & pickup checks if held, placed, or in hotbar
	if picked_up or placed or player == null or get_parent() == player.hotbar_storage or get_parent() == player.camera:
		return

	# --- Animate spin + float ---
	_time += delta
	rotate_y(deg_to_rad(spin_speed * delta))
	global_position.y = _base_y + sin(_time * float_speed) * float_amplitude

	# --- Check distance for pickup ---
	var dist = global_position.distance_to(player.global_position)
	if dist <= pickup_distance:
		_show_interaction_hint(true)
		if Input.is_action_just_pressed("interact"):
			_pickup()
	else:
		_show_interaction_hint(false)

# --- Player picks up barricade into hotbar ---
func _pickup():
	if picked_up or placed:
		return
	picked_up = true
	print("%s picked up!" % item_name)

	# Restore normal scale before giving to player
	scale = _original_scale

	if player and player.has_method("add_item_to_hotbar"):
		var success = player.add_item_to_hotbar(self)
		if not success:
			print("⚠️ Hotbar full — could not pick up %s!" % item_name)
			picked_up = false
	else:
		push_warning("⚠️ Player missing or has no 'add_item_to_hotbar' method!")

# --- Called when player uses the barricade from hotbar ---
func use_item():
	if not is_inside_tree() or player == null:
		return

	# Find camera (equipped or fallback)
	var camera: Camera3D = get_parent() if get_parent() is Camera3D else player.get_node_or_null("Head/Camera3D")
	if camera == null:
		push_warning("⚠️ Barricade: Camera not found!")
		return

	var instance = duplicate()
	instance.name = name + "_Placed"
	instance.placed = true

	# Restore original full scale when placed
	instance.scale = _original_scale

	var forward = -camera.global_transform.basis.z.normalized()
	instance.global_transform.origin = camera.global_transform.origin + forward * place_distance

	var rotation_y = camera.global_transform.basis.get_euler().y
	instance.rotation = Vector3(0, rotation_y, 0)

	_enable_collisions_recursive(instance)
	get_tree().current_scene.add_child(instance)
	print("✅ Barricade placed:", instance.name)

	# Remove self from hotbar after use
	if player.has_method("remove_item_from_hotbar"):
		player.remove_item_from_hotbar(player.current_hotbar_index)

	queue_free()

# --- When zombies attack or barricade takes damage ---
func take_damage(amount: int) -> void:
	health -= amount
	health = max(health, 0)
	print("🛡️ Barricade took", amount, "damage! HP:", health)
	if health <= 0:
		queue_free()
		print("💥 Barricade destroyed!")

# --- Helper: enable collisions recursively ---
func _enable_collisions_recursive(node: Node) -> void:
	if node is CollisionShape3D:
		node.disabled = false
	for child in node.get_children():
		_enable_collisions_recursive(child)

# --- Interaction prompt (debug/placeholder) ---
func _show_interaction_hint(visible: bool):
	if visible:
		print("Press [E] to pick up %s" % item_name)
