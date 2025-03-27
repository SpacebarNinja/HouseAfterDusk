extends Node

@onready var loading_scene = preload("res://Singletons/loading_screen.tscn")

func load_scene(current_scene: Node, next_scene: String) -> void:
	# Add loading scene to the root
	var loading_scene_instance = loading_scene.instantiate()
	get_tree().get_root().call_deferred("add_child", loading_scene_instance)
	
	# Start loading the scene asynchronously
	var error = ResourceLoader.load_threaded_request(next_scene)
	
	# Check for errors
	if error != OK:
		print("Error occurred while requesting scene load")
		return

	# Free the current scene
	current_scene.queue_free()

	# Small delay to let the loading screen appear
	await get_tree().create_timer(0.5).timeout

	# Progress bar reference
	var progress_bar = loading_scene_instance.get_node_or_null("ProgressBar")
	var animation_tree = loading_scene_instance.get_node_or_null("AnimationTree")
	
	# Monitor the loading process
	while true:
		var status = ResourceLoader.load_threaded_get_status(next_scene)
		
		# If still loading, simulate progress
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if progress_bar:
				progress_bar.value += 10  # Fake progress increase
				progress_bar.value = min(progress_bar.value, 100)  # Cap at 100%
				
		# If loading is complete, retrieve the scene
		elif status == ResourceLoader.THREAD_LOAD_LOADED:
			var scene = ResourceLoader.load_threaded_get(next_scene)
			if scene:
				get_tree().get_root().call_deferred("add_child", scene.instantiate())
			animation_tree.get("parameters/playback").travel("end_load")
			return
		
		# If there's an error, print and exit
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			print("Error occurred while loading the scene")
			return
		
		# Wait for a frame before checking again
		await get_tree().process_frame
