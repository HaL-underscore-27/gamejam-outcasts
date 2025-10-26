extends Node3D

# --- Configuration ---
@export var heal_amount: int = 20
@export var pickup_distance: float = 3.0
@export var item_name: String = "Pearto"

# --- Hand offset when equipped ---
@export var hand_position: Vector3 = Vector3(0.6, -0.4, -1.0)
@export var hand_rotation_degrees: Vector3 = Vector3(0, 0, 0)
@export var hand_scale: Vector3 = Vector3(0.1, 0.1, 0.1)

# --- Spin & Float settings ---
@export var spin_speed: float = 60.0          # degrees per second
@export var float_amplitude: float = 0.2      # vertical bobbing range
@export var float_speed: float = 2.0          # how fast it moves up/down
var _base_y: float = 0.0
var _time: float = 0.0

# --- State ---
var picked_up: bool = false
var player: Node = null

# --- References ---
@onready var mesh: MeshInstance3D = $MeshInstance3D if has_node("MeshInstance3D") else null
@onready var area: Area3D = $Area3D if has_node("Area3D") else null

func _ready():
	player = get_tree().root.get_node("Game/Player")
	if not player:
		push_warning("Player node not found!")
	_base_y = global_position.y
	set_process(true)

	set_process(true)

func _process(delta):
	# Skip if picked up or held
	if picked_up or player == null or get_parent() == player.hotbar_storage or get_parent() == player.camera:
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

func _pickup():
	if picked_up:
		return
	picked_up = true
	print("%s picked up!" % item_name)

	if player and player.has_method("add_item_to_hotbar"):
		player.add_item_to_hotbar(self)
	else:
		push_warning("Player does not have 'add_item_to_hotbar' method!")

# === When the item is used (from hotbar) ===
func use_item():
	print("%s eaten!" % item_name)
	_heal_player()
	
	# Tell player to remove this item from hotbar immediately
	if player and player.has_method("remove_item_from_hotbar"):
		player.remove_item_from_hotbar(player.current_hotbar_index)

	queue_free()  # remove from hand once used


func _heal_player():
	if player:
		player.health = clamp(player.health + heal_amount, 0, player.max_health)
		print("Healed %d HP! Current health: %d" % [heal_amount, player.health])
	else:
		print("%s could not heal: player not found." % item_name)

func _show_interaction_hint(visible: bool):
	if visible:
		print("Press [E] to pick up %s" % item_name)
