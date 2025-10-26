extends Node3D

@export var zombie_prototype: CharacterBody3D
#$"../Zombie"  It exists right here
@export var spawn_area_size: Vector2 = Vector2(20, 20) # Width x Depth of the square
@export var spawn_interval: float = 2.0 # Seconds between spawns
@export var max_zombies: int = 10

var zombies: Array = []
var spawn_timer: float = 0.0
func _ready() -> void:
	# Assign the prototype node from the scene tree
	if has_node("../Zombie"):
		zombie_prototype = get_node("../Zombie") as CharacterBody3D
		zombie_prototype.visible = false # hide the prototype
	else:
		push_warning("⚠️ Zombie prototype not found at ../Zombie")
func _process(delta: float) -> void:
	# Remove zombies that have been freed
	zombies = zombies.filter(func(z): return z and z.is_inside_tree())

	spawn_timer -= delta
	if spawn_timer <= 0.0 and zombies.size() < max_zombies:
		_spawn_zombie()
		spawn_timer = spawn_interval


func _spawn_zombie() -> void:
	if not zombie_prototype:
		push_warning("⚠️ No zombie prototype assigned!")
		return

	# Create RNG
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	# Generate a random position within the square zone
	var x = rng.randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2)
	var z = rng.randf_range(-spawn_area_size.y / 2, spawn_area_size.y / 2)
	var spawn_position = global_position + Vector3(x, 0, z)

	# Clone the existing zombie
	var zombie = zombie_prototype.duplicate()
	zombie.global_position = spawn_position
	add_child(zombie)
	zombies.append(zombie)
