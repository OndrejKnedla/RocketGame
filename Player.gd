extends RigidBody3D

##How mutch verthical force to apply when moving.
@export_range(750.0, 3000.0) var thrust: float = 1000.0
@export var torque_thrust: float = 100.0

var is_transitioning: bool = false

@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var booster_particles_2: GPUParticles3D = $BoosterParticles2
@onready var booster_particles_3: GPUParticles3D = $BoosterParticles3
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

#dash dash dash
#const move_speed = 8000.0
#const dash_speed = 40000.0
#const dash_duration = 0.2
#@onready var dash: Node3D = $Dash

func _process(delta: float) -> void:

#	if Input.is_action_just_pressed("dash"):
#		dash.start.dash(dash_duration)
#	var boost = dash_speed if dash.is.dashing() else move_speed 
	
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		booster_particles.emitting = true
		if rocket_audio.playing == false:
			rocket_audio.play()
	else:
		booster_particles.emitting = false
		rocket_audio.stop()
	
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0.0, 0.0, torque_thrust * delta))
		booster_particles_2.emitting = true
	else:
		booster_particles_2.emitting = false
		
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0.0, 0.0, -torque_thrust * delta))
		booster_particles_3.emitting = true
	else:
		booster_particles_3.emitting = false
		
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	#print(delta) 
		
func _on_body_entered(body: Node) -> void:
	if is_transitioning == false:
		if "Goal" in body.get_groups():
			complete_level(body.file_path)
		
		if "Floor" in body.get_groups():
			crash_sequence()
		
func crash_sequence() -> void:
	print("KABOOM!")
	explosion_particles.emitting = true
	explosion_audio.play()
	set_process(false)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_callback(get_tree().reload_current_scene)
	
func complete_level(next_level_file: String) -> void:
	print("Level Complete.")
	success_particles.emitting = true
	success_audio.play()
	set_process(false)
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))
