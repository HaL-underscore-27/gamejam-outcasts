extends Control

@export var empty_icon: Texture2D
@export var selected_color := Color(1, 1, 1)
@export var normal_color := Color(0.6, 0.6, 0.6)

var slot_icons: Array = []   # Icon TextureRects inside each slot
var slots: Array = []        # The slots themselves

func _ready() -> void:
	# Collect slots (TextureRects directly under this Control)
	for slot in get_children():
		if slot is TextureRect:
			slots.append(slot)
			# Assume each slot has a child TextureRect called "Icon"
			if slot.has_node("Icon"):
				var icon_node = slot.get_node("Icon")
				slot_icons.append(icon_node)
				icon_node.texture = empty_icon
				icon_node.visible = false  # start empty
			else:
				push_warning("Slot %s has no Icon child!" % slot.name)
				
func update_hotbar(items: Array, current_index: int) -> void:
	for i in range(len(slot_icons)):
		var icon_node = slot_icons[i]
		var slot = slots[i]

		if i < items.size() and items[i] and items[i].has_meta("icon"):
			icon_node.texture = items[i].get_meta("icon")
			icon_node.visible = true
		else:
			icon_node.texture = empty_icon
			icon_node.visible = false  # hide when slot empty

		# Highlight selected slot
		slot.modulate = selected_color if i == current_index else normal_color
