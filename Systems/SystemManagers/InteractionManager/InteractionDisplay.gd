extends Node2D

@export_category("Effect")
@export var sprite_hover_mod: Color = Color(1.5, 1.4, 1.2, 1)
@export var intr_display_hover_mod: Color = Color(1, 1, 1, 1)
@export var intr_display_original_mod: Color = Color(1, 1, 1, 0)
@export var intr_display_lift_offset: float = -4
@export var intr_display_max_shift: float = 10
@export_category("Speed")
@export var transition_speed: float = 10
@export var outer_ring_transition_speed: float = 10
@export var lift_speed: float = 3
@export var shift_speed: float = 15
@export_category("Base")
@onready var intr_display = %InteractionDisplay
@onready var intr_text = %IntrText
@onready var outer_ring = %OuterRing
@export_category("Fade Settings")
@export var alpha_start: float = 0
@export var alpha_end: float = 1
@export var fade_speed: float = 7.0

@onready var rings = $Rings
@onready var player = get_tree().get_first_node_in_group("Player")

var sprite_original_mod: Color
var sprite_target_mod: Color
var intr_original_mod: Color
var intr_target_mod: Color
var intr_display_original_pos: Vector2
var intr_display_target_pos: Vector2
var intr_text_size: float
var sprite_2d
var animation_progress: float = 0.0

var intr_duration: float = 1.0
var can_interact: bool = false
var inside_intr_area: bool = false

# We store the currently chosen interactable key and callback
var _current_key: String = ""
var _current_callback: Callable = Callable()

func _ready():
	intr_text_size = intr_text.get_size().x
	
	intr_original_mod = intr_display_original_mod
	intr_display.modulate = intr_original_mod
	intr_target_mod = intr_original_mod

	intr_display_original_pos = intr_display.position
	intr_display_target_pos = intr_display_original_pos

func on_intr_area_entered(sprite):
	sprite_2d = sprite
	sprite_original_mod = sprite_2d.modulate
	sprite_target_mod = sprite_hover_mod
	
	intr_target_mod = intr_display_hover_mod
	intr_display_target_pos = intr_display_original_pos + Vector2(0, intr_display_lift_offset)

	inside_intr_area = true
	
func on_intr_area_exited(sprite):
	sprite_2d = sprite
	sprite_target_mod = sprite_original_mod
	
	intr_target_mod = intr_display_original_mod
	intr_display_target_pos = intr_display_original_pos
	
	inside_intr_area = false

func update_intr_text():
	var keybind_events = [
		InputMap.action_get_events("InteractFirst"),
		InputMap.action_get_events("InteractSecond"),
		InputMap.action_get_events("InteractThird")
	]
	
	var text_list = []
	var keybind: String
	
	var i = 0
	for key in WorldManager.Interactables:
		i += 1
		# Determine the keybind for the current index
		if i <= keybind_events.size() and keybind_events[i - 1].size() > 0:
			keybind = keybind_events[i - 1][0].as_text().trim_suffix(" (Physical)")
		else:
			keybind = ""
		
		# Append the formatted text to the list
		var interactable_text = "%s [%s]" % [WorldManager.Interactables[key]["Text"], keybind]
		text_list.append(interactable_text)
	
	# Join the text list with newlines and update the interaction text
	intr_text.text = "\n".join(text_list)

func _process(delta):
	# Check if interaction is enabled
	if not HudManager.interaction_enabled:
		visible = false
		return
	visible = true

	# Always update the sprite's modulate for a smooth transition
	if is_instance_valid(sprite_2d):
		sprite_2d.modulate = sprite_2d.modulate.lerp(sprite_target_mod, transition_speed * delta)
	
	# Adjust base alpha regardless of interaction state
	var target_base_alpha = alpha_start if (HudManager.is_dialoguing or not inside_intr_area) else alpha_end
	modulate.a = lerp(modulate.a, target_base_alpha, fade_speed * delta)
	
	# If dialoguing or not inside the interaction area, skip further processing
	if HudManager.is_dialoguing or not inside_intr_area:
		return
	
	# --- Only runs when interactions are active ---
	var player_screen_pos = player.get_global_transform_with_canvas().get_origin()
	position = Vector2(player_screen_pos.x, player_screen_pos.y - 150)
	scale = Vector2(0.3, 0.3)
	
	var current_rings_x = rings.position.x
	rings.position = Vector2(current_rings_x, intr_text.position.y - 120)
	
	intr_display.modulate = intr_display.modulate.lerp(intr_target_mod, transition_speed * delta)
	intr_display.position = intr_display.position.lerp(intr_display_target_pos, lift_speed * delta)
	

	# Update the displayed text
	update_intr_text()

	# Outer ring fades out when we cannot interact
	if not can_interact:
		outer_ring.modulate = outer_ring.modulate.lerp(Color(1, 1, 1, 0), outer_ring_transition_speed * delta)
		# Allow new interactions when no key is held down
		if not (Input.is_action_pressed("InteractFirst") or Input.is_action_pressed("InteractSecond") or Input.is_action_pressed("InteractThird")):
			can_interact = true
		return

	# 1) Check if the player just pressed one of the interaction keys.
	var interacted_key = ""
	if Input.is_action_just_pressed("InteractFirst"):
		interacted_key = get_interactable_by_index(1)
	elif Input.is_action_just_pressed("InteractSecond"):
		interacted_key = get_interactable_by_index(2)
	elif Input.is_action_just_pressed("InteractThird"):
		interacted_key = get_interactable_by_index(3)

	if interacted_key != "":
		handle_interaction(interacted_key, delta)

	# 2) Gradually fade outer ring in or out based on its frame
	if outer_ring.frame == 0 or outer_ring.frame >= 49:
		outer_ring.modulate = outer_ring.modulate.lerp(Color(1, 1, 1, 0), outer_ring_transition_speed * delta)
	else:
		outer_ring.modulate = outer_ring.modulate.lerp(Color(1, 1, 1, 1), outer_ring_transition_speed * delta)

	# 3) Process held interaction key for the ring animation
	var key_index_held = 0
	if Input.is_action_pressed("InteractFirst"):
		key_index_held = 1
	elif Input.is_action_pressed("InteractSecond"):
		key_index_held = 2
	elif Input.is_action_pressed("InteractThird"):
		key_index_held = 3

	if key_index_held > 0:
		var current_held_key = get_interactable_by_index(key_index_held)
		if current_held_key != "":
			animation_progress += delta / intr_duration
			if animation_progress >= 1.0:
				animation_progress = 1.0
				can_interact = false  # Interaction is complete
				if _current_callback and _current_callback.is_valid():
					_current_callback.call()
				_current_callback = Callable()
			outer_ring.frame = int(animation_progress * 49)
		else:
			animation_progress = 0.0
			outer_ring.frame = 0
	else:
		animation_progress = 0.0
		outer_ring.frame = 0

func get_interactable_by_index(index: int) -> String:
	var i = 0
	for key in WorldManager.Interactables:
		i += 1
		if i == index:
			return key
	return ""

func handle_interaction(key: String, _delta):
	if WorldManager.Interactables.has(key):
		var interactable = WorldManager.Interactables[key]
		intr_duration = interactable["IntrDuration"]
		outer_ring.sprite_frames.set_animation_speed("default", 50 / intr_duration)

		if interactable.has("Callback"):
			_current_callback = interactable["Callback"]
		else:
			_current_callback = Callable()
		_current_key = key
		
