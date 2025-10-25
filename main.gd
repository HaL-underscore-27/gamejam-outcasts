extends Node3D

@onready var timer: Timer = get_tree().root.get_node("Game/UI/Timer")


var countdown = 10  # seconds

func _ready():
	timer.wait_time = 1
	timer.one_shot = false
	timer.start()
	print("Countdown started: %d seconds" % countdown)
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	countdown -= 1
	if countdown > 0:
		print("Time left: %d" % countdown)
	else:
		print("Countdown finished!")
		timer.stop()
