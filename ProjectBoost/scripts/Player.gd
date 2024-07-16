extends RigidBody3D

## The amount of force the rocket generates every frame
@export_range(750, 3000) var thrust: float = 1000
## The amount of toque the rocket generates every frame
@export var torque: float = 100

@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var right_booster_particles: GPUParticles3D = $RightBoosterParticles
@onready var left_booster_particles: GPUParticles3D = $LeftBoosterParticles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

var is_transitioning: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		if !rocket_audio.playing:
			rocket_audio.play()
			booster_particles.emitting = true
	else:
		rocket_audio.stop()
		booster_particles.emitting = false
		
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0, 0, torque * delta))
		right_booster_particles.emitting = true
	else:
		right_booster_particles.emitting = false
		
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0, 0, -torque * delta))
		left_booster_particles.emitting = true
	else:
		left_booster_particles.emitting = false


func _on_body_entered(body: Node) -> void:
	if !is_transitioning:
		if "Goal" in body.get_groups():
			complete_level(body.filepath)
		if "Hazard" in body.get_groups():
			crash_sequence()

func crash_sequence() -> void:
	print("CRASHED")
	explosion_particles.emitting = true
	
	# Get rocket to stop audio and particles
	left_booster_particles.emitting = false
	right_booster_particles.emitting = false
	booster_particles.emitting = false
	rocket_audio.stop()
	
	explosion_audio.play()
	
	# Disable _process function
	set_process(false)
	is_transitioning = true
	
	# Essentially make a timer, similar to await get_tree().create_timer(1).timeout
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().reload_current_scene)

func complete_level(next_level_file: String) -> void:
	print("FINISHED")
	success_particles.emitting = true
	success_audio.play()
	set_process(false)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))
