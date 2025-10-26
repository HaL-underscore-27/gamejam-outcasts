extends Area3D
class_name Bullet

@export var speed: float = 100.0
@export var damage: int = 30
@export var range: float = 50.0
@export var color: Color = Color.RED
@export var radius: float = 0.1

var distance_traveled := 0.0
var direction := Vector3.FORWARD

# Nodes
var mesh_instance: MeshInstance3D
var material: StandardMaterial3D

func _ready():
	direction = -global_transform.basis.z.normalized()
	connect("body_entered", Callable(self, "_on_body_entered"))

	# Create a small red sphere
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = SphereMesh.new()
	mesh_instance.scale = Vector3(radius, radius, radius)
	material = StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance.material_override = material
	add_child(mesh_instance)

	# Tween to fade out alpha over lifetime
	var tween = create_tween()
	tween.tween_property(material, "albedo_color:a", 0.0, range / speed)


func _physics_process(delta):
	var move_amount = speed * delta
	global_translate(direction * move_amount)
	distance_traveled += move_amount

	if distance_traveled > range:
		queue_free()

func _on_body_entered(body):
	if body is CharacterBody3D and body.has_method("take_damage"):
		body.take_damage(damage)
		print("💥 Hit", body.name, "for", damage, "damage!")
	queue_free()
