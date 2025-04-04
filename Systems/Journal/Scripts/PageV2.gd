extends Control   

@onready var journal_writing_sfx = $"../../JournalWritingSFX"
@onready var journal = $"../.."
@onready var add_button = $"../Add/AddButton"


var entry = ""
var words = []
var start_pos = Vector2(0, 0)
var limit_x = 1600
var line_spacing = 128
var word_spacing = 30

var WORD = preload("res://Systems/Journal/Scenes/Word.tscn")
var DROPDOWN_WORD = preload("res://Systems/Journal/Scenes/DropdownWord.tscn")

# Dictionary mapping each placeholder occurrence (id) to its selected word.
var selected_words = {}  # e.g. {0: "giant", 1: "bipedal creature", 2: "with scales}

var is_writing: bool = false
var played_writing_sfx: bool = false

# Dynamic dropdown options – keys must match the text following '%' in the test string.
var dropdown_options = {
	"height": ["giant", "tiny", "human-sized"], # (Lengthen for word wrap debugging)
	"shape": ["bipedal creature", "four-legged creature", "blob-like creature", "shapeshifting creature"],
	"features": ["with scales", "with fur", "with multiple limbs", "with gelatinous skin"],
	"action": ["is walking slowly", "is running fast", "is standing still"],
	"reaction": ["looks scared", "seems aggressive", "appears confused"],
	"methods": ["Method 1 for Monster", "Method 2 for Monster"]
}

# Array that keeps track of all token nodes (so they’re not removed on update)
var token_nodes := []

func _ready():
	is_writing = false
	call_deferred("update_text")
	add_button.connect("pressed", Callable(self, "_add_entry"))

func _add_entry():
	entry = " The entity, classified as an anomaly, has been identified as %height. It exhibits the characteristics of a %shape, notably %features that suggest possible evolutionary adaptations for survival. The observed behavior indicates that the creature %action in response to external stimuli and %reaction, implying an advanced or instinctual level of environmental awareness. Given its unpredictable nature, the recommended protocol involves %methods to ensure the safety of personnel and to contain the anomaly effectively."
	add_button.hide()
	
func _process(_delta):

	# Call update_text() each frame to check if the typewriter effect has finished or dropdowns are resolved.
	update_text()
	
	if is_writing and not played_writing_sfx:
		journal_writing_sfx.play()
		played_writing_sfx = true
	elif not is_writing and played_writing_sfx:
		journal_writing_sfx.stop()
		played_writing_sfx = false

func update_text():
	# Only update if the journal is open.
	if not journal.visible:
		is_writing = false
		return
		
	var current_entry = entry
	words = current_entry.split(" ")
	var current_pos = start_pos
	var placeholder_counter = 0
	var token_index = 0   # token we are processing
	var encountered_unresolved = false  # flag if an unresolved dropdown is reached
	
	# Process each word in the sentence.
	for word in words:
		# If there's a previous token and its typewriter effect hasn’t finished, stop processing.
		if token_index > 0 and token_index - 1 < token_nodes.size():
			var previous_token = token_nodes[token_index - 1]
			if not previous_token.has_revealed:
				is_writing = true
				break
		
		# If an unresolved dropdown has been encountered, do not process further tokens.
		if encountered_unresolved:
			is_writing = false
			break

		var punctuation = ""
		if word.ends_with("."):
			punctuation = "."
			word = word.trim_suffix(".")
		elif word.ends_with(","):
			punctuation = ","
			word = word.trim_suffix(",")
		
		var node = null
		# Process placeholder tokens.
		if word.begins_with("%"):
			var placeholder_key = word.substr(1, word.length())
			var resolved = selected_words.has(placeholder_counter) and selected_words[placeholder_counter] != "???"
			
			if token_index < token_nodes.size():
				node = token_nodes[token_index]
				node.placeholder_id = placeholder_counter
				node.placeholder_key = placeholder_key
				if resolved:
					node.set_word_text(selected_words[placeholder_counter] + punctuation)
				else:
					node.set_word_text("???")
					if not node.is_connected("continue_sentence", Callable(self, "continue_sentence")):
						node.connect("continue_sentence", Callable(self, "continue_sentence"), CONNECT_ONE_SHOT)
				node.set_dropdown_options(get_dropdown_options(placeholder_key))
			else:
				node = DROPDOWN_WORD.instantiate()
				token_nodes.append(node)
				add_child(node)
				node.placeholder_id = placeholder_counter
				node.placeholder_key = placeholder_key
				if resolved:
					node.set_word_text(selected_words[placeholder_counter] + punctuation)
				else:
					node.set_word_text("???")
					if not node.is_connected("continue_sentence", Callable(self, "continue_sentence")):
						node.connect("continue_sentence", Callable(self, "continue_sentence"), CONNECT_ONE_SHOT)
				node.set_dropdown_options(get_dropdown_options(placeholder_key))
			
			placeholder_counter += 1
			if not resolved:
				encountered_unresolved = true
		else:
			# Process normal word tokens.
			if token_index < token_nodes.size():
				node = token_nodes[token_index]
				# Do not call set_word_text() again so as not to reset the typewriter effect.
			else:
				node = WORD.instantiate()
				token_nodes.append(node)
				add_child(node)
				if node.has_method("set_hoverable"):
					node.set_hoverable(false)
				# Initialize the token text to start its typewriter effect.
				node.set_word_text(word + punctuation)
		# Update token position.
		var word_width = 0
		if node.has_method("get_minimum_size"):
			word_width = node.get_minimum_size().x
		else:
			word_width = node.size.x

		# Check if adding this token exceeds the limit and needs a new line.
		if current_pos.x + word_width > limit_x:
			current_pos.x = start_pos.x
			current_pos.y += line_spacing

		# Set token position after checking word wrap.
		node.set_position(current_pos)
		current_pos.x += word_width + word_spacing

		
		token_index += 1
		
		is_writing = false  # Assume all tokens are revealed
		for token in token_nodes:
			if "has_revealed" in token and not token.has_revealed:
				is_writing = true  # At least one token is still animating
				break  # Stop checking further since we found an unfinished token



func get_dropdown_options(placeholder_key: String) -> Array:
	if dropdown_options.has(placeholder_key):
		return dropdown_options[placeholder_key]
	return []

func continue_sentence():
	update_text()

# Called by a dropdown when its selection changes.
func update_selected_word(dropdown, selected_word):
	var id = dropdown.placeholder_id
	selected_words[id] = selected_word
	update_text()
