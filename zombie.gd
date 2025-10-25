extends CharacterBody3D

@export var speed: float = 2.0
@export var target_path: NodePath  # Reference to Player
@export var detection_radius: float = 5.0  # Distance at which zombie starts chasing

@onready var target: CharacterBody3D = get_node_or_null(target_path)

func _ready() -> void:
	if not target:
		# Try to auto-find the player if not assigned
		target = get_tree().get_first_node_in_group("player")
	
	if target:
		print("✅ Target set to:", target.name)
	else:
		push_warning("⚠️ No player found! Assign one in the inspector or add the player to 'player' group.")

func _physics_process(delta: float) -> void:
	if not target:
		return

	var distance_to_player = global_position.distance_to(target.global_position)

	if distance_to_player <= detection_radius:
		# Player is close, start chasing
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		
		# Make the zombie face the player (ignore Y rotation difference)
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z))

		print("🧟‍♂️ Zombie chasing", target.name)
	else:
		# Idle: stop moving
		velocity = Vector3.ZERO
		move_and_slide()
		print("😴 Zombie idle")
