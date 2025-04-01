extends Label  

signal continue_sentence  # Signal to notify when a word is selected

# New public properties.
var placeholder_id: int = -1
var placeholder_key: String = ""

var target_scale: Vector2 = Vector2(1.0, 1.0)
var lerp_speed: float = 15.0
var hitbox_rect: Rect2
var dropdown_open = false
var options_list = []  # Store options for the dropdown
var DROPDOWN_BUTTON = preload("res://Systems/Journal/Scenes/DropdownButton.tscn")
var y_gap := 150  # Space between buttons

var has_revealed = true  # Consider dropdown words as already revealed

# Fade variables
var target_alpha := 1.0
var fade_speed := 5.0  # Speed of fade

var button_delay_spawn := 0.1 # When spawning each option buttons, add a small delay

# Dropdown management
static var active_dropdown = null  # Track the active dropdown globally

@onready var temporary_word = $TemporaryWord
var hover_timer: Timer
var is_hovering_dropdown := false

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = get_minimum_size()
	set_dropdown_style()
	has_revealed = true

	# Add the hover timer
	hover_timer = Timer.new()
	hover_timer.wait_time = 0.1
	hover_timer.one_shot = true
	hover_timer.connect("timeout", Callable(self, "_on_hover_timeout"))
	add_child(hover_timer)

func set_word_text(new_text: String):
	text = new_text
	custom_minimum_size = get_minimum_size()

func set_dropdown_options(options: Array):
	options_list = options

func set_dropdown_style():
	self.modulate = Color(1, 1, 0)  # Always yellow
	self_modulate.a = 1.0  # Start with full alpha

func _process(delta):
	# CENTER PIVOT OFFSET
	pivot_offset.x = size.x / 2
	pivot_offset.y = size.y / 2
	
	scale = scale.lerp(target_scale, lerp_speed * delta)

	# LERP the alpha for smooth fade in/out
	self_modulate.a = lerp(self_modulate.a, target_alpha, fade_speed * delta)

	var local_mouse_pos = get_local_mouse_position() / scale
	hitbox_rect = Rect2(Vector2.ZERO, size)

	if hitbox_rect.has_point(local_mouse_pos):
		target_scale = Vector2(1.2, 1.2)
		if Input.is_action_just_pressed("click"):
			toggle_dropdown()
	else:
		target_scale = Vector2(1.0, 1.0)

func toggle_dropdown():
	if dropdown_open:
		#start_fade_out()
		close_dropdown()
	else:
		open_dropdown()

func open_dropdown():
	if options_list.size() == 0:
		return

	# Close the active dropdown if another one is already open
	if active_dropdown and active_dropdown != self:
		active_dropdown.close_dropdown()

	# Set the current dropdown as active
	active_dropdown = self

	dropdown_open = true
	is_hovering_dropdown = true  # Set hovering to true when opening dropdown
	target_alpha = 1.0  # Ensure dropdown is visible

	for i in range(options_list.size()):
		var option_button = DROPDOWN_BUTTON.instantiate()
		var actual_option_button = option_button.get_node("%Button")
		actual_option_button.set_option(options_list[i], self)
		actual_option_button.connect("mouse_entered", Callable(self, "_on_button_hovered"))
		actual_option_button.connect("mouse_exited", Callable(self, "_on_button_unhovered"))
		add_child(option_button)
		option_button.position = Vector2(0, size.y + (i * y_gap))
		await get_tree().create_timer(button_delay_spawn).timeout

func close_dropdown():
	for child in get_children():
		if child.has_node("%Button"):
			child.queue_free()
	dropdown_open = false
	target_alpha = 1.0  # Reset alpha instantly when closing
	if active_dropdown == self:
		active_dropdown = null

func select_option(selected_word: String):
	print("Selected word:", selected_word)
	set_word_text(selected_word)
	close_dropdown()
	var parent_node = get_parent()
	if parent_node.has_method("update_selected_word"):
		parent_node.update_selected_word(self, selected_word)
	emit_signal("continue_sentence")
