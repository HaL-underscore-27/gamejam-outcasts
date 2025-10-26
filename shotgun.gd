extends Node3D

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
