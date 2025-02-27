extends TextureRect

@export_category("Fade Settings")
@export var alpha_start: float = 1
@export var alpha_end: float = 0
@export var fade_speed: float = 7.0

func _ready():
	visible = true

func _process(delta):
	var target_alpha = alpha_start if HudManager.is_dialoguing else alpha_end
	
	modulate.a = lerp(modulate.a, target_alpha, fade_speed * delta)
