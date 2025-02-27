extends Control

@export_category("Fade Settings")
@export var y_start: float = 40
@export var y_end: float = 0
@export var alpha_start: float = 0
@export var alpha_end: float = 1
@export var speed: float = 5.0

func _ready():
	# Set initial values
	position.y = y_start
	modulate.a = alpha_start

func _process(delta):
	position.y = lerp(position.y, y_end, speed * delta)
	modulate.a = lerp(modulate.a, alpha_end, speed * delta)
