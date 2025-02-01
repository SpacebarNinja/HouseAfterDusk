extends Node2D

@onready var backpack = get_tree().get_first_node_in_group("Backpack")
@onready var switch_static_sfx = $SwitchStatic
@onready var turn_on_sfx = $TurnOn
@onready var static_sfx = $Static
@onready var rooms = $"../../.."
@onready var television_light = $TelevisionLight

@export var interaction_area: Area2D
@export var tilemap: TileMapLayer
@export_category("ChannelColors")
@export var StaticChannelColors: Array[Color]
@export var ChannelColors1: Array[Color]
@export var ChannelColors2: Array[Color]
@export var ChannelColors3: Array[Color]
@export var ChannelColors4: Array[Color]
@export var CorruptChannelColors1: Array[Color]
@export var CorruptChannelColors2: Array[Color]
@export var CorruptChannelColors3: Array[Color]
@export var CorruptChannelColors4: Array[Color]
@export var color_change_speed: float = 1.0

var channels: Dictionary = {
	"Static": "Static",
	"Channel 1": "Safe",
	"Channel 2": "Safe",
	"Channel 3": "Safe",
	"Channel 4": "Safe",
}

@onready var channel_bg_audio = [
	$ChannelBGAudio1,
	$ChannelBGAudio2,
	$ChannelBGAudio3,
	$ChannelBGAudio4
]

var current_channel: int = 0  # Start with Static channel
var is_on: bool
var has_power := true
var is_remote_equipped := false
var current_color_index: int = 0
var next_color_index: int = 1
var color_lerp_value: float = 0.0
var TVCoords := Vector2i(0, -1)

var can_interact: bool = false

func on_intr_area_entered():
	can_interact = true
	handle_text()

func on_intr_area_exited():
	can_interact = false
	erase_buttons()

func _ready():
	television_light.hide()

func _process(delta):
	# Check if remote is equipped or not
	var item = backpack.get_equipped_item()
	var remote_status = item and item.get_property("id", "") == 'tv_remote'

	if remote_status != is_remote_equipped:
		is_remote_equipped = remote_status
		handle_text()
	
	# Adjust audio volume based on current room
	for audio in channel_bg_audio:
		if rooms.is_outside == true:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index(audio.bus), -5)
		else:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index(audio.bus), 5)
	
	# Update television light color if the TV is on
	if is_on:
		_update_light_color(delta)
		
	if WorldManager.is_generator_on == false:
		is_on = false
		_on_button_turn_off_pressed()

func handle_text():
	if not has_power:
		return
	
	if not can_interact:
		return
	
	if is_remote_equipped and not is_on:
		erase_buttons()
		WorldManager.add_interactable("Turn On TV", 0.5, Callable(self, "_on_button_turn_on_pressed"))
	
	elif not is_on:
		erase_buttons()
		WorldManager.add_interactable("Turn On TV", 1.5, Callable(self, "_on_button_turn_on_pressed"))
	
	elif is_remote_equipped:
		erase_buttons()
		WorldManager.add_interactable("Turn Off TV", 0.5, Callable(self, "_on_button_turn_off_pressed"))
		WorldManager.add_interactable("Switch Channel", 0.5, Callable(self, "_on_switch_channel_button_pressed"))
	else:
		erase_buttons()
		WorldManager.add_interactable("Turn Off TV", 1.5, Callable(self, "_on_button_turn_off_pressed"))

func erase_buttons():
	WorldManager.Interactables.erase("Turn Off TV")
	WorldManager.Interactables.erase("Turn On TV")
	WorldManager.Interactables.erase("Switch Channel")
		
func _on_button_turn_on_pressed():
	turn_on_sfx.play()
	is_on = true
	television_light.show()
	tilemap.set_cell(TVCoords, 0, Vector2i(1, 0))
	var timer = get_tree().create_timer(0.2)
	await timer.timeout
	tilemap.set_cell(TVCoords, 0, Vector2i(3, 0))
	static_sfx.play()

	handle_text()
	
func _on_button_turn_off_pressed():
	tilemap.set_cell(TVCoords, 0, Vector2i(5, 4))
	var timer = get_tree().create_timer(0.2)
	await timer.timeout
	tilemap.set_cell(TVCoords, 0, Vector2i(0, 0))
	is_on = false
	television_light.hide()
	_stop_all_channel_audio()
	_reset_color_indices()
	static_sfx.stop()
	
	handle_text()

func _on_switch_channel_button_pressed():
	current_channel += 1
	if current_channel > 4:
		current_channel = 0  # Loop back to Static

	tilemap.set_cell(TVCoords, 0, Vector2i(3, 0))
	static_sfx.stop()

	_reset_color_indices()  # Reset indices for the new channel
	_update_channel_display()


func _update_channel_display():
	# Play switch sound
	switch_static_sfx.play()

	var timer = get_tree().create_timer(0.5)
	await timer.timeout

	# Define the atlas coordinates for Static and safe/corrupted channels
	var safe_coords = {
		1: Vector2i(0, 1),
		2: Vector2i(3, 1),
		3: Vector2i(0, 2),
		4: Vector2i(3, 2),
	}

	var corrupted_coords = {
		1: Vector2i(3, 3),
		2: Vector2i(0, 3),
		3: Vector2i(0, 4),
		4: Vector2i(3, 4),
	}

	if current_channel == 0:  # Static channel
		_reset_color_indices()
		print("Static")
		_stop_all_channel_audio()
	else:
		# Get the current channel key
		var channel_key = "Channel %d" % current_channel

		# Set the correct tile and play audio if safe
		if channels[channel_key] == "Safe":
			tilemap.set_cell(TVCoords, 0, safe_coords[current_channel])
			_play_channel_audio(current_channel)
			_reset_color_indices()
			print(channel_key)
		else:
			tilemap.set_cell(TVCoords, 0, corrupted_coords[current_channel])
			_stop_all_channel_audio()
			print("Corrupted %s" % channel_key)
			
	handle_text()

func _stop_all_channel_audio():
	for audio in channel_bg_audio:
		audio.stop()
	static_sfx.stop()

func _play_channel_audio(channel_index: int):
	_stop_all_channel_audio()  # Ensure all other audio stops
	if channel_index >= 1 and channel_index <= 4:
		channel_bg_audio[channel_index - 1].play()  # Adjust for 0-based indexing

func _reset_color_indices():
	# Reset the color indices for the current channel
	current_color_index = 0
	next_color_index = 1
	color_lerp_value = 0.0

func _update_light_color(delta):
	# Get the appropriate channel color array
	var color_array: Array[Color]
	if current_channel == 0:
		color_array = StaticChannelColors
	else:
		match current_channel:
			1:
				color_array = ChannelColors1
			2:
				color_array = ChannelColors2
			3:
				color_array = ChannelColors3
			4:
				color_array = ChannelColors4

	# Ensure the array has at least one color
	if color_array.size() > 0:
		if current_color_index >= color_array.size():
			current_color_index = 0
		if next_color_index >= color_array.size():
			next_color_index = (current_color_index + 1) % color_array.size()

		# Get current and next colors
		var current_color = color_array[current_color_index]
		var next_color = color_array[next_color_index if color_array.size() > 1 else 0]

		# Interpolate each color component (r, g, b, a)
		var interpolated_color = Color(
			lerp(current_color.r, next_color.r, color_lerp_value),
			lerp(current_color.g, next_color.g, color_lerp_value),
			lerp(current_color.b, next_color.b, color_lerp_value),
			lerp(current_color.a, next_color.a, color_lerp_value)
		)

		# Assign the interpolated color to the light
		television_light.color = interpolated_color

		# Increment the interpolation value
		color_lerp_value += delta * color_change_speed

		# Advance to the next color when fully interpolated
		if color_lerp_value >= 1.0:
			color_lerp_value = 0.0
			current_color_index = next_color_index
			next_color_index = (next_color_index + 1) % color_array.size() if color_array.size() > 1 else 0
