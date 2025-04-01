extends Control 

@export var button_path: NodePath

var target_scale = Vector2(5.1, 5.1)
var target_modulate = Color(1, 1, 1, 1)
var speed = 10.0

var actual_button: Button

func _ready():
	actual_button = get_node_or_null(button_path)

	target_scale = Vector2(5.1, 5.1)
	target_modulate = Color(0.8, 0.8, 0.8, 1)

	if actual_button:
		actual_button.connect("mouse_entered", Callable(self, "_on_button_mouse_entered"))
		actual_button.connect("mouse_exited", Callable(self, "_on_button_mouse_exited"))
		actual_button.connect("button_down", Callable(self, "_on_button_button_down"))
		actual_button.connect("button_up", Callable(self, "_on_button_button_up"))
		actual_button.connect("pressed", Callable(self, "_on_button_pressed"))

func _process(delta):
	# Apply smooth scaling and color transition
	scale = scale.lerp(target_scale, delta * speed)
	modulate = modulate.lerp(target_modulate, delta * speed)

func _on_button_mouse_entered():
	target_scale = Vector2(5.5, 5.5)
	target_modulate = Color(1, 1, 1, 1)
	speed = 10.0

func _on_button_mouse_exited():
	target_scale = Vector2(5.1, 5.1)
	target_modulate = Color(0.8, 0.8, 0.8, 1)
	speed = 10.0

func _on_button_button_down():
	target_scale = Vector2(5.1, 5.1)
	target_modulate = Color(1.5, 0.8, 0.8, 1)
	speed = 30.0

func _on_button_button_up():
	target_scale = Vector2(5.5, 5.5)
	target_modulate = Color(1, 1, 1, 1)
	speed = 10.0
