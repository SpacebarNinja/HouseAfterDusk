extends Control

var test_string = "This is a test sentence that should wrap correctly. Lorem ipsum dolor sit amet, consectetur adipiscing elit. In suscipit blandit egestas. Morbi venenatis at orci eget laoreet. Pellentesque non imperdiet eros, sit amet faucibus mauris. Sed vel vulputate ipsum. Aenean sed fermentum elit. Fusce sit amet augue quis enim placerat viverra. Morbi sollicitudin porttitor sapien quis faucibus. Morbi iaculis quam vel nisl sodales faucibus. In finibus pulvinar justo, et aliquam nunc posuere at."
var words = test_string.split(" ")  # Split into words
var start_pos = Vector2(0, 0)  # Starting position
var limit_x = 1200  # Change this based on your journal width
var line_spacing = 120  # How far down each new line goes
var word_spacing = 30
var WORD = preload("res://Systems/Journal/Word.tscn")  # Load the word scene

var last_test_string = ""  # Store the last known string to detect changes

func _ready():
	#global_position = start_pos
	update_text()

func _process(delta):
	# If the text has changed, update the words
	if test_string != last_test_string:
		update_text()
		last_test_string = test_string

func update_text():
	# Clear previous words
	for child in get_children():
		child.queue_free()
	
	words = test_string.split(" ")  # Split into words
	var current_pos = start_pos
	
	for word in words:
		var word_instance = WORD.instantiate()  # Create new word node
		word_instance.set_text(word)  # Assuming your scene has a method to set text
		
		add_child(word_instance)
		word_instance.set_position(current_pos)
		
		# Check if adding this word exceeds the limit
		var word_size = word_instance.get_minimum_size().x  # Get width of word
		if current_pos.x + word_size > limit_x:
			# Move to new line
			current_pos.x = start_pos.x
			current_pos.y += line_spacing
		else:
			# Otherwise, move to the right
			current_pos.x += word_size + word_spacing
