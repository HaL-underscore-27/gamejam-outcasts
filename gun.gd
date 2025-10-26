extends Node3D

# Item properties for hotbar
var hand_position = Vector3(0.3, -0.2, -0.5)
var hand_rotation_degrees = Vector3(0, 0, 0)
var hand_scale = Vector3(0.5, 0.5, 0.5)

# Bullet reference (the one in the scene)
@onready var bullet_template = get_node("/root/Game/Bullet")
var can_shoot = true
var shoot_cooldown = 0.2

func use_item():
	shoot()

func shoot():
	if not can_shoot or not bullet_template:
		return
	
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	# Muzzle flash effect
	_create_muzzle_flash(camera)
	
	var bullet = bullet_template.duplicate()
	get_tree().root.get_node("Game").add_child(bullet)
	
	var spawn_offset = 0.5
	bullet.global_position = camera.global_position + (-camera.global_transform.basis.z * spawn_offset)
	bullet.direction = -camera.global_transform.basis.z
	bullet.speed = 150.0
	bullet.visible = true
	bullet.lifetime = 3.0
	
	print("🔫 Shot fired!")
	
	can_shoot = false
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true

func _create_muzzle_flash(camera: Camera3D):
	var flash = OmniLight3D.new()
	camera.add_child(flash)
	flash.light_energy = 3.0
	flash.light_color = Color.ORANGE
	flash.omni_range = 2.0
	
	# Flash disappears quickly
	await get_tree().create_timer(0.05).timeout
	flash.queue_free()
