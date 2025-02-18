extends AnimationBase

@onready var journal = get_tree().get_first_node_in_group("Journal")
@onready var anim_sprite = $AnimatedSprite2D
@export var audio_list: Array[AudioStreamPlayer2D]
@export var timer_list: Array[Timer]

var direction: String
var idle_played: bool = false
var right_click_moving: bool = false
var StepParticleScene = preload("res://Systems/Particles/StepParticle.tscn")

func enter():
	timer_list[0].start()

func exit():
	idle_played = false
	timer_list[0].stop()

func _process(_delta):
	handle_animation()
	handle_footsteps()

func handle_animation():
	if WorldManager.StopGeneMovement: return
	
	var player_instance = get_node("/root/MainScene/Player")
	var distance_to_mouse = player_instance.distance_to_mouse
	var altmove_sprint_distance = player_instance.altmove_sprint_distance

	var horizontal_input = Input.get_action_strength("WalkRight") - Input.get_action_strength("WalkLeft")
	var vertical_input = Input.get_action_strength("WalkDown") - Input.get_action_strength("WalkUp")
	var anim_vector = Vector2(horizontal_input, vertical_input)

	if horizontal_input == 1:
		flip_sprite(false)
	elif horizontal_input == -1:
		flip_sprite(true)

	var alternative_move_pressed = Input.is_action_pressed("AlternativeMove")
	var sprint_pressed = Input.is_action_pressed("Sprint")
	var can_sprint = player.can_sprint

	# Alternative movement logic
	var backpack_instance = get_node("/root/MainScene/Hud/MechanicHud/Backpack/BackpackInventory/BackpackSprite")
	var is_hovering_inventory = backpack_instance.is_hovering_inventory
	if alternative_move_pressed and anim_vector == Vector2.ZERO and distance_to_mouse > 10 and !is_hovering_inventory:
		right_click_moving = true
		var mouse_position = get_global_mouse_position()
		var mouse_direction = (mouse_position - player.global_position).normalized()
		if mouse_direction.x < 0:
			flip_sprite(true)
		else:
			flip_sprite(false)

		var is_sprinting = (sprint_pressed or distance_to_mouse > altmove_sprint_distance) and can_sprint
		if is_sprinting:
			animation_tree.get("parameters/playback").travel("Sprint")
		else:
			animation_tree.get("parameters/playback").travel("Walk")
	else:
		right_click_moving = false
		# Keyboard movement logic
		if anim_vector == Vector2.ZERO:
			animation_tree.get("parameters/playback").travel("Idle1")
			if timer_list[0].is_stopped() and not idle_played:
				animation_tree.get("parameters/playback").travel("Idle2")
				await animation_player.animation_finished
				idle_played = true
		else:
			var is_sprinting = sprint_pressed and can_sprint
			if is_sprinting:
				animation_tree.get("parameters/playback").travel("Sprint")
			else:
				animation_tree.get("parameters/playback").travel("Walk")

		timer_list[0].start()
		idle_played = false

func handle_footsteps():
	var walk_footstep_frames := [1, 6]
	var sprint_footstep_frames := [1, 5]
	var animation_state = anim_sprite.animation.split("_")[0]
	#print(animation_state)
	if animation_state == 'Sprint' and anim_sprite.frame in sprint_footstep_frames:
		basic_play_audio(0, true)
	elif animation_state == 'Walk' and anim_sprite.frame in walk_footstep_frames:
		basic_play_audio(0, false)
		
	
func flip_sprite(flip: bool):
	if flip:
		direction = "left"
		anim_sprite.flip_h = true
		anim_sprite.offset.x = 6
	else:
		direction = "right"
		anim_sprite.flip_h = false
		anim_sprite.offset.x = 0

func get_direction() -> String:
	var player_instance = get_node("/root/MainScene/Player")
	if player_instance.velocity.x < 0:
		return "left"
	else:
		return "right"

func basic_play_audio(index: int, is_sprinting: bool):
	if index >= 0 and index < audio_list.size():
		var audio = audio_list[index]
		if is_sprinting:
			audio.pitch_scale = 1.5
		else:
			audio.pitch_scale = 1.0
			
		audio.play()
		if index == 0:
			spawn_particle()
	else:
		print("Invalid audio index: ", index)

func spawn_particle():
	var step_particle_instance = StepParticleScene.instantiate()
	if randi() % 100 < 30:
		step_particle_instance.amount = 2
	add_child(step_particle_instance)
	step_particle_instance.emitting = true
	step_particle_instance.z_index = -1
