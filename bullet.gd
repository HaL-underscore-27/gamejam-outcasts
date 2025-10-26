extends Area3D

var speed = 100.0
var damage = 25
var direction = Vector3.ZERO
var lifetime = 5.0

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Auto-destroy after lifetime
	if visible:  # Only set timer if this is an active bullet
		await get_tree().create_timer(lifetime).timeout
		queue_free()

func _physics_process(delta):
	if visible:
		position += direction * speed * delta

func _on_body_entered(body):
	print("💥 Bullet hit:", body.name)
	if body.is_in_group("enemy") or "Zombie" in body.name:
		if body.has_method("take_damage"):
			body.take_damage(damage)
	if visible:  # Only destroy active bullets, not the template
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemy"):
		if area.has_method("take_damage"):
			area.take_damage(damage)
	if visible:
		queue_free()
