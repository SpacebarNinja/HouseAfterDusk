# Rooms.gd
extends Node2D

# Cabin Room Area Detectors =---------------------------------------------------
@onready var area_living_room = $"../RoomDetection/Living Room"
@onready var area_bathroom = $"../RoomDetection/Bathroom"
@onready var area_kitchen = $"../RoomDetection/Kitchen"
@onready var area_hallway = $"../RoomDetection/Hallway"
@onready var area_bedroom = $"../RoomDetection/Bedroom"
@onready var area_storage = $"../RoomDetection/Storage"
@onready var area_electrical = $"../RoomDetection/Electrical"

# Forest Room Area Detectors =--------------------------------------------------
@onready var area_outside_cabin = $"../RoomDetection/OutsideCabin"
@onready var area_crop_field = $"../RoomDetection/CropField"

# Cabin Room Tilemaps =---------------------------------------------------------
@onready var living_room = $"CabinNodes/Living Room"
@onready var bathroom = $CabinNodes/Bathroom
@onready var kitchen = $CabinNodes/Kitchen
@onready var hallway = $CabinNodes/Hallway
@onready var bedroom = $CabinNodes/Bedroom
@onready var storage = $CabinNodes/Storage
@onready var electrical = $CabinNodes/Electrical

# Forest Room Tilemaps =--------------------------------------------------------
@onready var outside_cabin = $ForestNodes/OutsideCabin
@onready var crop_field = $ForestNodes/CropField

# Others =----------------------------------------------------------------------
@onready var door_sfx = $"../DoorSFX"

@onready var ambient_electrical = $CabinNodes/Electrical/AmbientElectrical
@onready var ambient_sparks = $CabinNodes/Electrical/AmbientSparks

var cabin_rooms = []
var forest_rooms = []
var current_room = null
var old_room = null

var transition_time = 0.4
var transition_timer = 0.0
var is_transitioning = false

var is_room_bounds_x: bool = false
var is_room_bounds_y: bool = false
var is_outside: bool

var is_electrical_ambient_playing: bool = false

func _ready():
	old_room = null
	cabin_rooms = [living_room, bathroom, kitchen, hallway, bedroom, storage, electrical]
	forest_rooms = [outside_cabin, crop_field]
	reset_rooms()

func reset_rooms():
	for room in cabin_rooms:
		room.visible = false
		room.collision_enabled = false
		room.modulate.a = 1.0
		room.z_index = -15
		for child in room.get_children():
			if child is TileMapLayer:
				child.collision_enabled = false
				
	for room in forest_rooms:
		room.visible = false
		room.collision_enabled = false
		room.modulate.a = 1.0
		room.z_index = -15
		for child in room.get_children():
			if child is TileMapLayer:
				child.collision_enabled = false
				
func show_room(room):
	if current_room == room:
		return

	old_room = current_room
	current_room = room
	is_room_bounds_x = false
	is_room_bounds_y = false

	current_room.visible = true
	current_room.collision_enabled = true
	current_room.z_index = 0
	for child in current_room.get_children():
		if child is TileMapLayer:
			child.collision_enabled = true

	current_room.modulate.a = 0.0
	is_transitioning = true
	transition_timer = 0.0

	# Push old_room back if it exists
	if old_room and old_room != current_room:
		old_room.z_index = -15
		old_room.visible = true
		old_room.collision_enabled = true
		old_room.modulate.a = 1.0
		for child in old_room.get_children():
			if child is TileMapLayer:
				child.collision_enabled = true
		door_sfx.play()
	
	if current_room in cabin_rooms:
		is_outside = false
	elif current_room in cabin_rooms:
		is_outside = true
		
func _process(delta):
	if is_transitioning:
		transition_timer += delta
		var t = clamp(transition_timer / transition_time, 0.0, 1.0)
		current_room.modulate.a = lerp(0.0, 1.0, t)
		if t >= 1.0:
			is_transitioning = false
			#print("Transition complete for room:", current_room.name)
			if old_room:
				old_room.visible = false
	
	handle_ambient_noises()
	
func handle_ambient_noises():
	if current_room.name == 'Electrical':
		if not is_electrical_ambient_playing:
			play_electrical_ambient()
	else:
		if is_electrical_ambient_playing:
			stop_electrical_ambient()

func play_electrical_ambient():
	ambient_electrical.play()
	ambient_sparks.play()
	is_electrical_ambient_playing = true

func stop_electrical_ambient():
	ambient_electrical.stop()
	ambient_sparks.stop()
	is_electrical_ambient_playing = false
		
func _on_living_room_area_entered(_area):
	print("Entered Living Room area")
	show_room(living_room)

func _on_bathroom_area_entered(_area):
	print("Entered Bathroom area")
	show_room(bathroom)

func _on_kitchen_area_entered(_area):
	print("Entered Kitchen area")
	show_room(kitchen)

func _on_hallway_area_entered(_area):
	print("Entered Hallway area")
	show_room(hallway)

func _on_bedroom_area_entered(_area):
	print("Entered Bedroom area")
	show_room(bedroom)

func _on_storage_area_entered(_area):
	print("Entered Storage area")
	show_room(storage)

func _on_electrical_area_entered(_area):
	print("Entered Electrical area")
	show_room(electrical)
	
func _on_outside_cabin_area_entered(_area):
	print("Exited Cabin")
	show_room(outside_cabin)

func _on_crop_field_area_entered(_area):
	print("At Crop Field")
	show_room(crop_field)
	
func _on_cam_x_living_room_area_entered(_area):
	is_room_bounds_x = true

func _on_cam_x_living_room_area_exited(_area):
	is_room_bounds_x = false

func _on_cam_y_living_room_area_entered(_area):
	is_room_bounds_y = true

func _on_cam_y_living_room_area_exited(_area):
	is_room_bounds_y = false
