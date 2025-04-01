extends Label

var target_scale: Vector2 = Vector2(1.0, 1.0)  # Scale, not size
var lerp_speed: float = 15.0
var hitbox_rect: Rect2  # Store the hitbox for visualization
var is_hoverable: bool = false  # Controls hover behavior

var original_word: String = ""  # Store the full word
var reveal_speed: float = 0.05  # Speed of revealing letters (seconds per letter)
var word_progress: int = 0  # Tracks how many letters are shown
var reveal_timer: float = 0.0  # Accumulates delta time for reveal
var has_revealed: bool = false  # Prevent re-animation after initial reveal
var show_full_first: bool

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = get_minimum_size()
	self_modulate.a = 0.0

func set_word_text(new_text: String):
	# If the word hasn't changed, skip reanimation
	if original_word == new_text and has_revealed:
		return
	
	original_word = new_text
	text = original_word  # Show full word instantly
	custom_minimum_size = get_minimum_size()
	word_progress = 0
	reveal_timer = 0.0
	show_full_first = true  # Ready to instantly start typewriter effect
	has_revealed = false  # Reset reveal status when the word changes

func _process(delta):
	# If the word is already revealed, skip the animation
	if has_revealed:
		return

	# Instantly transition to typewriter effect after showing full word
	if show_full_first:
		text = ""  # Clear the text instantly after showing full
		word_progress = 0
		show_full_first = false
		self_modulate.a = 1.0

	# Handle letter reveal
	if word_progress < original_word.length():
		reveal_timer += delta
		if reveal_timer >= reveal_speed:
			reveal_timer -= reveal_speed  # Reset timer after revealing
			word_progress += 1
			text = original_word.substr(0, word_progress)
			custom_minimum_size = get_minimum_size()

	# If the word is fully revealed, mark as revealed to prevent re-animation
	if word_progress >= original_word.length():
		has_revealed = true
