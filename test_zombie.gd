extends CharacterBody3D

# === Movement & attack ===
@export var speed: float = 2.0
@export var barricade_detection_radius: float = 1.0
@export var player_detection_radius: float = 40.0
@export var attack_range: float = 1.5
@export var attack_damage: int = 10
@export var attack_cooldown: float = 0.5

# === Health ===
@export var max_health: int = 50
var health: int = max_health

# === Node references ===
@onready var target: CharacterBody3D = get_tree().root.get_node("Game/Player") if has_node("/root/Game/Player") else null
@onready var anim_player: AnimationPlayer = $zombiemodel/AnimationPlayer

var attack_timer: float = 0.0
var gravity: float = 9.8

# Barricade currently being attacked
var barricade_target: Node3D = null

func _ready() -> void:
	if not target:
		push_warning("⚠️ No player found at path: Player")
	else:
		print("✅ Target set to:", target.name)
	add_to_group("characters")

func _physics_process(delta: float) -> void:
	if not target:
		return

	velocity.y -= gravity * delta

<<<<<<< HEAD
	# Find closest barricade
	barricade_target = _find_closest_barricade_in_range(barricade_detection_radius)

	# Decide main target
	var attack_target: Node3D = barricade_target if barricade_target else null
	if not attack_target:
=======
	# Find closest barricade within its detection radius
	barricade_target = _find_closest_barricade_in_range(barricade_detection_radius)

	# Decide main target: barricade if within its radius, otherwise player
	var attack_target: Node3D = null
	if barricade_target:
		attack_target = barricade_target
	else:
		# Only chase player if within player detection range
>>>>>>> 68e04d3170727346b804bc12d3440c8c28be5972
		var distance_to_player = global_position.distance_to(target.global_position)
		if distance_to_player <= player_detection_radius:
			attack_target = target

	if not attack_target:
<<<<<<< HEAD
=======
		# Nothing to chase or attack
>>>>>>> 68e04d3170727346b804bc12d3440c8c28be5972
		if anim_player.current_animation != "idle":
			anim_player.play("idle")
		return

	var distance_to_target = global_position.distance_to(attack_target.global_position)

	# Move towards target
	if distance_to_target > attack_range:
		var direction = attack_target.global_position - global_position
		direction.y = 0
		if direction.length() > 0:
			direction = direction.normalized()
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

	# Face target
	look_at(Vector3(attack_target.global_position.x, global_position.y, attack_target.global_position.z))

	# Animation
	if distance_to_target <= attack_range:
		if anim_player.current_animation != "attack":
			anim_player.play("attack")
	elif velocity.length() > 0:
		if anim_player.current_animation != "walk":
			anim_player.play("walk")
	else:
		if anim_player.current_animation != "idle":
			anim_player.play("idle")

	# Attack logic
	attack_timer -= delta
	if distance_to_target <= attack_range and attack_timer <= 0.0:
		_attack_target(attack_target)
		attack_timer = attack_cooldown


<<<<<<< HEAD
=======
# Find closest barricade within a given radius
>>>>>>> 68e04d3170727346b804bc12d3440c8c28be5972
func _find_closest_barricade_in_range(radius: float) -> Node3D:
	var closest: Node3D = null
	var closest_dist = INF
	for barricade in get_tree().get_nodes_in_group("barricades"):
		if barricade is Node3D:
			var dist = global_position.distance_to(barricade.global_position)
			if dist <= radius and dist < closest_dist:
				closest = barricade
				closest_dist = dist
	return closest


<<<<<<< HEAD
=======
# Attack function
>>>>>>> 68e04d3170727346b804bc12d3440c8c28be5972
func _attack_target(attack_target: Node3D) -> void:
	if attack_target.has_method("take_damage"):
		attack_target.take_damage(attack_damage)
		print("🧟‍♂️ Zombie attacked", attack_target.name, "for", attack_damage, "HP")


# === NEW: Take damage function ===
func take_damage(amount: int) -> void:
	print("took damage")
	health -= amount
	print("🧟 Zombie took ", amount, " damage! HP:", health)
	if health <= 0:
		print("☠️ Zombie died!")
		queue_free()
