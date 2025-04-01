extends Button

var parent_dropdown = null  # Ref to the dropdown for passing back data
var option_text = ""  # The word this button represents

@onready var dropdown_button = $"../../../.."

# Animation parameters
var lerp_speed := 10.0
var target_shift := 0.0
var target_alpha := 1.0  # Target alpha for fade-in
var temp_position_x: float = -50
func _ready():
	connect("pressed", Callable(self, "_on_button_pressed"))
	set_process(true)  # Enable _process for animation
	dropdown_button.self_modulate.a = 0.0  # Start invisible for fade-in

func set_option(text_string: String, dropdown):
	option_text = text_string
	self.text = ' ' + option_text + ' '
	parent_dropdown = dropdown
	

func _process(delta):
	dropdown_button.self_modulate.a = lerp(self_modulate.a, target_alpha, lerp_speed * delta)
	temp_position_x = lerp(temp_position_x, target_shift, lerp_speed * delta)
	
	dropdown_button.position.x = temp_position_x
	
func _on_button_pressed():
	if parent_dropdown:
		parent_dropdown.select_option(option_text)
