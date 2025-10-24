extends Node3D

@onready var timer = $CountdownTimer
@onready var label = $Label3D

var countdown = 10  # seconds

func _ready():
	countdown = int(timer.wait_time)
	label.text = "Time left: %d" % countdown
	timer.start()
	set_process(true)

func _process(delta):
	if timer.time_left > 0:
		countdown = int(timer.time_left)
		label.text = "Time left: %d" % countdown
	else:
		label.text = "Countdown finished!"
		set_process(false)
