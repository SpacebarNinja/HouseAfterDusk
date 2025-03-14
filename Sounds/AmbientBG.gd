extends AudioStreamPlayer

@onready var rooms = $"../ROOMS"

func _process(_delta):
	if rooms and is_instance_valid(rooms) and rooms.current_room and is_instance_valid(rooms.current_room):
		if str(rooms.current_room.name) == 'OUTSIDE':
			set_bus('Ambient BG')
		else:
			set_bus('Muffled')

func _ready():
	playing = true
