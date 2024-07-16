extends RigidBody3D

## The amount of force the rocket generates every frame
@export_range(750, 3000) var thrust: float = 1000
## The amount of toque the rocket generates every frame
@export var torque: float = 100

var is_transitioning: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0, 0, torque * delta))
		
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0, 0, -torque * delta))


func _on_body_entered(body: Node) -> void:
	if !is_transitioning:
		if "Goal" in body.get_groups():
			complete_level(body.filepath)
		if "Hazard" in body.get_groups():
			crash_sequence()

func crash_sequence() -> void:
	print("CRASHED")
	
	# Disable _process function
	set_process(false)
	is_transitioning = true
	
	# Essentially make a timer, similar to await get_tree().create_timer(1).timeout
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(get_tree().reload_current_scene)

func complete_level(next_level_file: String) -> void:
	print("FINISHED")
	set_process(false)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))
