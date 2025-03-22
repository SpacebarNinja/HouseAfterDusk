extends Node

@onready var transition_animation = null
@onready var transition_node = null
@onready var player = null

var zoom_out_amount = -1.0
var zoom_in_amount = 1.0
var original_zoom = 3.2

func _ready():
	# Set up UI transitions
	call_deferred("_setup_ui_nodes")

func _setup_ui_nodes():
	var main_scene = get_node_or_null("/root/MainScene")
	if main_scene:
		transition_animation = main_scene.get_node_or_null("Hud/BGProcessing/Transition/AnimationPlayer")
		transition_node = main_scene.get_node_or_null("Hud/BGProcessing/Transition")

func switch_map(new_map_path: String, player_position: Vector2, transition_type: String = ""):
	if not ResourceLoader.exists(new_map_path):
		print("❌ ERROR: Map scene does not exist! Check path:", new_map_path)
		return
	
	# TRANSITION
	if transition_animation:
		transition_node.visible = true
		transition_animation.play("transition_in")
		await transition_animation.animation_finished

	# Get MainScene correctly
	var main_scene = get_node_or_null("/root/MainScene")
	if not main_scene:
		print("❌ ERROR: MainScene not found in tree!")
		return
	
	# Get current map, making sure it's actually a child of MainScene
	var current_map = null
	for child in main_scene.get_children():
		if child.is_in_group("Map"):  # Ensure maps are grouped properly
			current_map = child
			break

	if current_map:
		main_scene.remove_child(current_map)
		current_map.queue_free()
	else:
		print("⚠️ WARNING: No current map found, switching anyway.")

	# Load new map safely
	var new_map = load(new_map_path)
	if not new_map or not new_map.can_instantiate():
		print("❌ ERROR: Failed to load map:", new_map_path)
		return

	var new_map_instance = new_map.instantiate()
	main_scene.add_child(new_map_instance)  # Correctly add it under MainScene
	new_map_instance.set_owner(main_scene)  # Ensure proper scene ownership

	# Move player safely
	player = get_tree().get_first_node_in_group("Player")
	if player:
		player.global_position = player_position

	# Reset camera position & apply transition zoom effect
	HudManager.camera_movement = false
	var camera = get_tree().get_first_node_in_group("MainCamera")
	if camera:
		if transition_type == 'zoom_in':
			camera.apply_zoom_transition(Vector2(original_zoom + zoom_out_amount, original_zoom + zoom_out_amount))
		else:
			camera.apply_zoom_transition(Vector2(original_zoom + zoom_in_amount, original_zoom + zoom_in_amount))
		camera.reset_camera_position(player.global_position)
	
	# Re-fetch UI elements
	call_deferred("_setup_ui_nodes")

	if transition_animation:
		transition_animation.play("transition_out")
		await transition_animation.animation_finished
		transition_node.visible = false
