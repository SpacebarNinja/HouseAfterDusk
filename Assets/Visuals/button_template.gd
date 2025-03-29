extends Control

@export var icon: TextureRect

var target_scale = Vector2(1, 1)
var target_modulate = Color(1, 1, 1, 1)
var speed = 10.0

func _ready():
	# Get the  node dynamically based on the path
	# Set default target values
	target_scale = Vector2(1, 1)
	target_modulate = Color(0.8, 0.8, 0.8, 0.8)
	if icon: icon.hide()
	
	# Ensure the actual button exists before connecting signals
	connect("mouse_entered", Callable(self, "_on_button_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_button_mouse_exited"))
	connect("button_down", Callable(self, "_on_button_button_down"))
	connect("button_up", Callable(self, "_on_button_button_up"))
	connect("pressed", Callable(self, "_on_button_pressed"))

func _process(delta):
	# Apply smooth scaling and color transition
	scale = scale.lerp(target_scale, delta * speed)
	modulate = modulate.lerp(target_modulate, delta * speed)

func _on_button_mouse_entered():
	target_scale = Vector2(1.1, 1.1)
	target_modulate = Color(1, 1, 1, 1)
	speed = 10.0
	if icon: icon.show()

func _on_button_mouse_exited():
	target_scale = Vector2(1, 1)
	target_modulate = Color(0.8, 0.8, 0.8, 1)
	speed = 10.0
	if icon: icon.hide()

func _on_button_button_down():
	target_scale = Vector2(1.05, 1.05)
	target_modulate = Color(1.5, 0.8, 0.8, 1)
	speed = 30.0

func _on_button_button_up():
	target_scale = Vector2(1.1, 1.1)
	target_modulate = Color(1, 1, 1, 1)
	speed = 10.0
