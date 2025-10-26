extends Node3D

# --- Configuration ---
@export var heal_amount: int = 20   # HP restored when eaten
@export var pickup_distance: float = 3.0
@export var item_name: String = "Pearto"

# --- Hand offset when equipped ---
@export var hand_position: Vector3 = Vector3(0.6, -0.4, -1.0)
@export var hand_rotation_degrees: Vector3 = Vector3(0, 0, 0)
@export var hand_scale: Vector3 = Vector3(0.1, 0.1, 0.1)

# --- Icon texture for hotbar UI ---
@export var icon_texture: Texture2D = preload("res://images/IMG_2063_1200x1200_crop_center.webp")  # Replace with your pear icon path

# --- State ---
var picked_up: bool = false
var player: Node = null

# --- References ---
@onready var mesh: MeshInstance3D = $MeshInstance3D if has_node("MeshInstance3D") else null
@onready var area: Area3D = $Area3D if has_node("Area3D") else null

func _ready():
	# Find player automatically
	player = get_tree().root.get_node("Game/Player") # <-- adjust path if needed
	if not player:
		push_warning("Player node not found. Check the path!")

	# Set the icon metadata so UI can access it
	set_meta("icon", icon_texture)

	set_process(true)

func _process(_delta):
	if picked_up or player == null:
		return

	# Check distance to player
	var dist = global_position.distance_to(player.global_position)
	if dist <= pickup_distance:
		_show_interaction_hint(true)

		# Pickup with 'E' key
		if Input.is_action_just_pressed("interact"):
			_pickup()
	else:
		_show_interaction_hint(false)

func _pickup():
	if picked_up:
		return
	picked_up = true

	print("%s picked up!" % item_name)

	# Add to player's hotbar (the Player script handles hiding & reparenting)
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
	# Optional placeholder — can be replaced with UI prompts later
	if visible:
		print("Press [E] to pick up %s" % item_name)
