extends CharacterBody3D

@export var speed: float = 2.0
@export var target_path: NodePath = "Player"  # Path relative to Game node
@export var detection_radius: float = 5.0  # Distance at which zombie starts chasing
@export var attack_range: float = 1.5  # Distance at which zombie can attack
@export var attack_damage: int = 10
@export var attack_cooldown: float = 0.5  # Seconds between attacks

@onready var target: CharacterBody3D = null
@onready var anim_player: AnimationPlayer = $zombiemodel/AnimationPlayer

var attack_timer: float = 0.0

func _ready() -> void:
	# Get the target using the specified path relative to parent (Game node)
	if target_path != NodePath("") and not target:
		target = get_parent().get_node_or_null(target_path) as CharacterBody3D

	# Debug / warning
	if target:
		print("✅ Target set to:", target.name)
	else:
		push_warning("⚠️ No player found at path:", target_path)

func _physics_process(delta: float) -> void:
	if not target:
		return

	var distance_to_player = global_position.distance_to(target.global_position)

	if distance_to_player <= detection_radius:
		# Player is close, start chasing
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

		# Face the player (ignore Y rotation difference)
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z))

		# Play walk animation if not attacking
		if anim_player.current_animation != "walk" and attack_timer <= 0.0:
			anim_player.play("walk")

		# Attack logic
		attack_timer -= delta
		if distance_to_player <= attack_range and attack_timer <= 0.0:
			_attack_player()
			attack_timer = attack_cooldown
	else:
		# Idle: stop moving
		velocity = Vector3.ZERO
		move_and_slide()

		# Play idle animation if not attacking
		if anim_player.current_animation != "idle" and attack_timer <= 0.0:
			anim_player.play("idle")

		# Reset attack timer if player is out of range
		attack_timer = 0.0

func _attack_player() -> void:
	# Play attack animation
	if anim_player.has_animation("attack"):
		anim_player.play("attack")

	# Deal damage
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)
		print("🧟‍♂️ Zombie attacked", target.name, "for", attack_damage, "HP")
	else:
		print("⚠️ Target has no take_damage() method")
