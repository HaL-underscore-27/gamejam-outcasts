extends CharacterBody3D

@export var speed: float = 2.0
@export var detection_radius: float = 20.0
@export var attack_range: float = 1.5
@export var attack_damage: int = 10
@export var attack_cooldown: float = 0.5

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

func _physics_process(delta: float) -> void:
	if not target:
		return

	velocity.y -= gravity * delta

	# Find closest barricade within attack range
	barricade_target = _find_closest_barricade_in_range()

	# Decide main target: barricade if nearby, otherwise player
	var attack_target: Node3D = barricade_target if barricade_target else target
	var distance_to_target = global_position.distance_to(attack_target.global_position)

	# Move towards target if out of attack range
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

	# Face the target
	look_at(Vector3(attack_target.global_position.x, global_position.y, attack_target.global_position.z))

	# Animation handling
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

# Find closest barricade within attack_range
func _find_closest_barricade_in_range() -> Node3D:
	var closest: Node3D = null
	var closest_dist = INF
	for barricade in get_tree().get_nodes_in_group("barricades"):
		if barricade is Node3D:
			var dist = global_position.distance_to(barricade.global_position)
			if dist <= attack_range and dist < closest_dist:
				closest = barricade
				closest_dist = dist
	return closest

# Attack function
func _attack_target(attack_target: Node3D) -> void:
	if attack_target.has_method("take_damage"):
		attack_target.take_damage(attack_damage)
		print("🧟‍♂️ Zombie attacked", attack_target.name, "for", attack_damage, "HP")
