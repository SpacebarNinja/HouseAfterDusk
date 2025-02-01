extends AudioStreamPlayer

@onready var rooms = $"../ROOMS"

func _process(_delta):
	if str(rooms.current_room.name) == 'OUTSIDE':
		set_bus('Ambient BG')
	else:
		set_bus('Muffled')

func _ready():
	playing = true
