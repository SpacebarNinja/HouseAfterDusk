extends CanvasModulate

const DAY_LENGTH = 2400
const MIDNIGHT = 0
const SUNRISE = 560
const NOON = 1120
const SUNSET = 1680

const MAX_BRIGHTNESS = 90
const MIN_BRIGHTNESS = 35

const MAX_SUN_COLOR = 45
const MIN_SUN_COLOR = 30

var BRIGHTNESS_HOLD = 400
var BRIGHTNESS_TRANSITION = 100
var SUN_COLOR_HOLD = -20
var SUN_COLOR_TRANSITION = 0

const REDUCED_CABIN_BRIGHTNESS = 30
const REDUCED_CABIN_SUN_COLOR = 10

@export var generator_off_darkness: int = 20
@export var generator_transition_time: float = 1.0  # Duration of generator transition

@onready var rooms = get_node_or_null("/root/MainScene/MapCabin/ROOMS")

var target_brightness: float = 0.0
var current_brightness: float = 0.0
var target_sun_color: float = 0.0
var current_sun_color: float = 0.0

func _ready():
	# Initialize brightness and sun color based on the current world time
	var world_time = WorldManager.WorldTime
	var base_brightness = get_brightness(world_time)
	var base_sun_color = get_sun_color(world_time)
	
	# Adjust for cabin darkness and generator state
	base_brightness = clamp(base_brightness - REDUCED_CABIN_BRIGHTNESS, MIN_BRIGHTNESS, base_brightness)
	base_sun_color = clamp(base_sun_color - REDUCED_CABIN_SUN_COLOR, MIN_SUN_COLOR, base_sun_color)
	
	# Set both target and current values to avoid visual popping
	target_brightness = base_brightness
	current_brightness = base_brightness
	target_sun_color = base_sun_color
	current_sun_color = base_sun_color
	
	# Apply the initial color
	color = Color.from_hsv(0, current_sun_color / 100.0, current_brightness / 100.0, 1)
	
func _process(delta):
	if not is_instance_valid(rooms):
		rooms = get_node_or_null("/root/MainScene/MapCabin/ROOMS")
		
	var world_time = WorldManager.WorldTime
	var base_brightness = get_brightness(world_time)
	var base_sun_color = get_sun_color(world_time)
	
	# Make cabin darker than outside
	if is_instance_valid(rooms) and rooms and rooms.current_room:
		if str(rooms.current_room.name) != 'OUTSIDE':
			base_brightness = clamp(base_brightness - REDUCED_CABIN_BRIGHTNESS, MIN_BRIGHTNESS, base_brightness)
			base_sun_color = clamp(base_sun_color - REDUCED_CABIN_SUN_COLOR, MIN_SUN_COLOR, base_sun_color)
			
			if not WorldManager.is_generator_on:
				# Adjust target values when generator is off
				target_brightness = clamp(base_brightness - generator_off_darkness, MIN_BRIGHTNESS - generator_off_darkness, base_brightness)
				target_sun_color = base_sun_color
			else:
				# Normal brightness when generator is on
				target_brightness = base_brightness
				target_sun_color = base_sun_color
	else:
		target_brightness = base_brightness
		target_sun_color = base_sun_color

	# Smoothly interpolate to target brightness and sun color
	current_brightness = lerp(current_brightness, target_brightness, delta / generator_transition_time)
	current_sun_color = lerp(current_sun_color, target_sun_color, delta / generator_transition_time)
	
	# Update color
	color = Color.from_hsv(0, current_sun_color / 100.0, current_brightness / 100.0, 1)

func get_brightness(world_time: int) -> float:
	world_time = world_time % DAY_LENGTH
	
	var start_min_hold_end = BRIGHTNESS_HOLD
	var start_rise_end = NOON - BRIGHTNESS_HOLD
	var _noon_hold_start = NOON - BRIGHTNESS_HOLD
	var noon_hold_end = NOON + BRIGHTNESS_HOLD
	var _end_fall_start = NOON + BRIGHTNESS_HOLD
	var end_min_hold_start = DAY_LENGTH - BRIGHTNESS_HOLD
	
	if world_time <= start_min_hold_end:
		return MIN_BRIGHTNESS
	elif world_time <= start_rise_end:
		return smooth_lerp(MIN_BRIGHTNESS, MAX_BRIGHTNESS, world_time, start_min_hold_end, start_rise_end)
	elif world_time <= noon_hold_end:
		return MAX_BRIGHTNESS
	elif world_time <= end_min_hold_start:
		return smooth_lerp(MAX_BRIGHTNESS, MIN_BRIGHTNESS, world_time, noon_hold_end, end_min_hold_start)
	else:
		return MIN_BRIGHTNESS

func get_sun_color(world_time: int) -> float:
	world_time = world_time % DAY_LENGTH

	var sunrise_hold_start = SUNRISE - SUN_COLOR_HOLD
	var sunrise_hold_end = SUNRISE + SUN_COLOR_HOLD

	var noon_hold_start = NOON - SUN_COLOR_HOLD
	var noon_hold_end = NOON + SUN_COLOR_HOLD

	var sunset_hold_start = SUNSET - SUN_COLOR_HOLD
	var sunset_hold_end = SUNSET + SUN_COLOR_HOLD

	var end_cycle_start = DAY_LENGTH - SUN_COLOR_HOLD

	if world_time < sunrise_hold_start:
		return smooth_lerp(MIN_SUN_COLOR, MAX_SUN_COLOR, world_time, MIDNIGHT, sunrise_hold_start)
	elif world_time <= sunrise_hold_end:
		return MAX_SUN_COLOR
	elif world_time < noon_hold_start:
		return smooth_lerp(MAX_SUN_COLOR, MIN_SUN_COLOR, world_time, sunrise_hold_end, noon_hold_start)
	elif world_time <= noon_hold_end:
		return MIN_SUN_COLOR
	elif world_time < sunset_hold_start:
		return smooth_lerp(MIN_SUN_COLOR, MAX_SUN_COLOR, world_time, noon_hold_end, sunset_hold_start)
	elif world_time <= sunset_hold_end:
		return MAX_SUN_COLOR
	elif world_time < end_cycle_start:
		return smooth_lerp(MAX_SUN_COLOR, MIN_SUN_COLOR, world_time, sunset_hold_end, end_cycle_start)
	else:
		return MIN_SUN_COLOR

func smooth_lerp(from_val: float, to_val: float, current_time: float, start_time: float, end_time: float) -> float:
	if start_time == end_time:
		return from_val
	var t = float(current_time - start_time) / float(end_time - start_time)
	t = clamp(t, 0.0, 1.0)
	return lerp(from_val, to_val, t)
