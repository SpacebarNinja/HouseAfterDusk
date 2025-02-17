extends Entity_Class

@export_category("ElectronicGuy Stats")
@export var glitch_frequency: int = 3
@export var glitch_length: float = 0.2

@export_category("Teleport Stats")
@export var teleport_max_speed: int = 100
@export var teleport_min_speed: int = 50
@export var teleport_frequency: int = 5
@export var teleport_min_hide_length: float = 1.0
@export var teleport_max_hide_length: float = 10.0

#------------{ Electronic Guy Nodes }------------
@onready var vision_timer = $VisionTimer
@onready var teleport_timer = $TeleportTimer
@onready var glitch_timer = $GlitchTimer

var is_glitching = false
var is_teleporting = false
var hide_length

func _ready():
	teleport_timer.wait_time = randi_range(round(teleport_frequency / 2), teleport_frequency) # Reset teleport timer

func _physics_process(delta):
	handle_glitch_effect()
	handle_teleport_effect()
	#print('timer: ', teleport_timer)
	#print('teleporting?: ', is_teleporting)
	#print('hide_length: ', hide_length)
	if PlayerFound:
		var player_angle = rad_to_deg(get_angle_to(get_player_position()))
		handle_vision_cone(player_angle, delta)

func handle_glitch_effect():
	if glitch_timer.is_stopped() and not is_glitching:
		start_glitch()

func start_glitch():
	is_glitching = true
	anim_sprite.play("Glitch")
	anim_sprite.frame = randi() % 9 + 1  # Random frame from 1 to 9
	glitch_timer.wait_time = glitch_length
	glitch_timer.start()
	
func end_glitch():
	anim_sprite.play("Idle")
	is_glitching = false
	glitch_timer.wait_time = randi_range(glitch_frequency, round(glitch_frequency/2))
	
func handle_teleport_effect():
	if teleport_timer.is_stopped() and not is_teleporting:
		start_teleport()

func start_teleport():
	is_teleporting = true
	movement_speed = randi_range(teleport_min_speed, teleport_max_speed)  # Set random teleport speed
	anim_sprite.play("Teleport") # Play teleport anim then hide
	await anim_sprite.animation_finished
	vision_cone.hide()
	anim_sprite.hide()
	
	wander()
	teleport_timer.wait_time = randf_range(teleport_min_hide_length, teleport_max_hide_length)
	teleport_timer.start()

func end_teleport():
	if is_teleporting:
		teleport_timer.wait_time = randi_range(teleport_frequency, round(teleport_frequency/2)) # Reset teleport timer
		movement_speed = 0  # Stop movement
		anim_sprite.show() # Show TvG
		vision_cone.show()
		anim_sprite.play_backwards("Teleport")
		await anim_sprite.animation_finished
		anim_sprite.play("Idle")
		is_teleporting = false
		
func _on_player_found():
	vision_timer.start()
	teleport_timer.stop()
	
func _on_player_lost():
	if not vision_timer.is_stopped():
		teleport_timer.start()
		
func _on_glitch_timer_timeout():
	end_glitch()
	
func _on_teleport_timer_timeout():
	end_teleport()
	
func _on_vision_timer_timeout():
	if player_detected:
		print("Attacking")
	else:
		print("Searching")
