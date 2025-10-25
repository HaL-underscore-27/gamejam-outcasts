extends MeshInstance3D

func _ready():
	# Get the Area3D child node
	var area = $Area3D
	# Connect the body_entered signal to our function
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if the body that entered is the Player
	if body.name == "Player" or body.is_in_group("player"):
		# Make the cube disappear
		queue_free()  # This removes the node completely
		# Alternative: self.visible = false  # This just hides it
