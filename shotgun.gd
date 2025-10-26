extends Node3D

<<<<<<< HEAD
# --- Damage & range ---
@export var damage: int = 9999      # instantly kills
@export var range: float = 50.0
@export var fov_degrees: float = 10.0  # cone width in degrees

# --- Hotbar hand info ---
@export var hand_position: Vector3 = Vector3(2, -1, -2)
@export var hand_rotation_degrees: Vector3 = Vector3(0, 0, 0)
@export var hand_scale: Vector3 = Vector3(0.1, 0.1, 0.1)

# --- Triggered when player presses LMB ---
func use_item():
	_fire_from_screen_center()
func _fire_from_screen_center():
	# Get player Camera3D
	var player = get_tree().root.get_node("Game/Player")
	if not player:
		push_warning("❌ Player node not found!")
		return

	var head = player.get_node("Head")
	if not head:
		push_warning("❌ Head node not found under Player!")
		return

	var camera = head.get_node("Camera3D")
	if not camera:
		push_warning("❌ Camera3D not found under Head!")
		return

	# --- Shoot from the head/eye position ---
	var head_offset = Vector3(0, -2, -0.225)  # y and z offsets of the head
	var origin = camera.global_transform.origin + head_offset

	# Forward vector of camera
	var forward = -camera.global_transform.basis.z.normalized()

	# Optional: slightly raise the shot for natural aiming
	var upward_adjust = Vector3(0, 0.05, 0)  # tweak to your preference
	forward = (forward + upward_adjust).normalized()

	# --- Damage calculation ---
	for character in get_tree().get_nodes_in_group("characters"):
		if not character.has_method("take_damage"):
			continue

		var to_target = character.global_transform.origin - origin
		var distance = to_target.length()
		if distance > range:
			continue

		var angle_deg = rad_to_deg(forward.angle_to(to_target.normalized()))
		if angle_deg <= fov_degrees / 2:
			character.take_damage(damage)
			print("💥 Instantly killed ", character.name, "distance:", distance, "angle:", angle_deg)
=======
@export var damage: int = 30
@export var range: float = 50.0
@export var bullet_speed: float = 100.0
@export var hand_position: Vector3 = Vector3(3, -2, -3)
@export var hand_rotation_degrees: Vector3 = Vector3(0, 0, 0)
@export var hand_scale: Vector3 = Vector3(0.3, 0.3, 0.3)

var muzzle_position := Vector3(0, 0, -1)

func use_item():
	_fire_bullet()

func _fire_bullet():
	var bullet = Bullet.new()  # ✅ works now because class_name Bullet is declared
	bullet.global_transform = global_transform.translated(global_transform.basis.z * -1)
	bullet.damage = damage
	bullet.speed = bullet_speed
	bullet.range = range
	get_tree().current_scene.add_child(bullet)
	print("🔫 Shotgun fired!")
>>>>>>> 68e04d3170727346b804bc12d3440c8c28be5972
