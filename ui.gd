extends CanvasLayer

@onready var label: Label = $PlaytimeLabel

var elapsed_time: float = 0.0  # in seconds

func _process(delta: float) -> void:
	# Add delta every frame
	elapsed_time += delta

	# Calculate minutes and seconds
	var minutes = int(elapsed_time / 60)
	var seconds = int(elapsed_time) % 60

	# Format text as mm:ss
	label.text = "⏱  %02d:%02d" % [minutes, seconds]
