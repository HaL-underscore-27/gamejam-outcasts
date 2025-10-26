extends Label

@export var player_path: NodePath = "/Game/Player"
var player: Node = null

func _ready():
	# Try to find the player safely
	if player_path and has_node(player_path):
		player = get_node(player_path)
	else:
		print("⚠️ Player not found at path:", player_path)

	# Set position + style for bottom-left corner
	_setup_ui_style()

	# Initialize the text display
	_update_health()

func _process(delta):
	if player:
		_update_health()

func _update_health():
	if player:
		text = "❤️ " + str(player.health) + " / " + str(player.max_health)

# --- Position and style setup ---
func _setup_ui_style():
	# Anchor to bottom-left corner
	anchor_left = 0.0
	anchor_top = 1.0
	anchor_right = 0.0
	anchor_bottom = 1.0

	# Offset from the screen corner
	offset_left = 20
	offset_bottom = -40
	offset_top = -60
	offset_right = 200

	# Make it look nice
	horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	add_theme_color_override("font_color", Color(1, 0.2, 0.2)) # soft red
	add_theme_font_size_override("font_size", 28)
