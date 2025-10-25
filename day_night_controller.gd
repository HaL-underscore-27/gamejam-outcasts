extends Node3D

@onready var sun: DirectionalLight3D = get_parent().get_node("Sun")
@onready var world_env: WorldEnvironment = get_parent().get_node("WorldEnvironment")


@export var day_duration_minutes: float = 1.0

@export var night_duration_minutes: float = 1.0
# should be 5 or 10 for both

var elapsed_time: float = 0.0
var total_cycle_seconds: float

func _ready() -> void:
	if not sun:
		push_error("Sun node not found!")
	if not world_env:
		push_error("WorldEnvironment node not found!")
	elif not world_env.environment:
		push_error("WorldEnvironment has no Environment assigned!")

	total_cycle_seconds = (day_duration_minutes + night_duration_minutes) * 60

func _process(delta: float) -> void:
	elapsed_time += delta
	var cycle_pos = fmod(elapsed_time, total_cycle_seconds)

	# Sun rotation
	var t = cycle_pos / total_cycle_seconds
	var sun_angle = lerp(-90, 270, t)
	sun.rotation_degrees.x = sun_angle

	var env = world_env.environment
	if not env:
		return

	if cycle_pos < day_duration_minutes * 60:
		var day_t = cycle_pos / (day_duration_minutes * 60)
		sun.light_energy = lerp(0.2, 2.0, day_t)
		env.ambient_light_color = Color(0.1,0.1,0.3).lerp(Color(1,1,1), day_t)
	else:
		var night_t = (cycle_pos - day_duration_minutes*60) / (night_duration_minutes*60)
		sun.light_energy = lerp(2.0, 0.2, night_t)
		env.ambient_light_color = Color(1,1,1).lerp(Color(0.1,0.1,0.3), night_t)
