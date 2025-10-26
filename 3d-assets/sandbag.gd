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

# --- State ---
var picked_up: bool = false
var player: Node = null

# --- References ---
@onready var mesh: MeshInstance3D = $MeshInstance3D if has_node("MeshInstance3D") else null
@onready var collider: StaticBody3D = $StaticBody3D if has_node("StaticBody3D") else null

func _ready():
	player = get_tree().root.get_node("Game/Player")
	if not player:
		push_warning("Player node not found!")

	add_to_group("barricades")  # For zombies to find
	set_process(true)

func _process(_delta):
	if picked_up or player == null:
		return

	var dist = global_position.distance_to(player.global_position)
	if dist <= pickup_distance:
		_show_interaction_hint(true)
		if Input.is_action_just_pressed("interact"):
			_pickup()
	else:
		_show_interaction_hint(false)

func _pickup():
	if picked_up:
		return
	picked_up = true

	print("%s picked up!" % item_name)

	if player and player.has_method("add_item_to_hotbar"):
		player.add_item_to_hotbar(self)
	else:
		push_warning("Player does not have 'add_item_to_hotbar' method!")

func use_item():
	# Place barricade in front of camera
	if not is_inside_tree() or player == null:
		return

	var camera: Camera3D = get_parent() if get_parent() and get_parent() is Camera3D else player.get_node("Camera3D") if player.has_node("Camera3D") else null
	if camera == null:
		print("⚠️ Barricade: Camera not found!")
		return

	var instance = duplicate()
	instance.name = name + "_Placed"

	var forward = -camera.global_transform.basis.z.normalized()
	instance.global_transform.origin = camera.global_transform.origin + forward * place_distance

	var rotation_y = camera.global_transform.basis.get_euler().y
	instance.rotation = Vector3(0, rotation_y, 0)

	_enable_collisions_recursive(instance)

	get_tree().current_scene.add_child(instance)
	print("Barricade placed:", instance.name)

	# Remove self from hotbar
	if player.has_method("remove_item_from_hotbar"):
		player.remove_item_from_hotbar(player.current_hotbar_index)
	queue_free()

# --- Called by zombie when attacking ---
func take_damage(amount: int) -> void:
	health -= amount
	health = max(health, 0)
	print("🛡️ Barricade took", amount, "damage! HP:", health)
	if health <= 0:
		queue_free()
		print("💥 Barricade destroyed!")

func _enable_collisions_recursive(node: Node) -> void:
	if node is CollisionShape3D:
		node.disabled = false
	for child in node.get_children():
		_enable_collisions_recursive(child)

func _show_interaction_hint(visible: bool):
	if visible:
		print("Press [E] to pick up %s" % item_name)
