extends Control

@onready var game_panel = $CanvasLayer/GameWindow
@onready var canvas_layer = $CanvasLayer

const DEBUG_PANEL_COORD = Vector2(176, 16)
var WindowDict: Dictionary
var debugs_open: bool
func _ready():
	WindowDict = {
		"enemy_panel": $CanvasLayer/EnemyWindow,
		"map_panel": $CanvasLayer/MapWindow,
		"player_panel": $CanvasLayer/PlayerWindow,
		"inventory_panel": $CanvasLayer/InventoryWindow,
		"hud_panel": $CanvasLayer/HudWindow
	}
	
	game_panel.hide()
	for key in WindowDict.keys():
		WindowDict[key].hide()
	
func _process(_delta):
	if Input.is_action_just_pressed("DebugMenu"):
		debugs_open = not debugs_open  # Toggle the state
		if debugs_open:
			open_debug_menu()
		else:
			close_debug_menu()
	
func open_debug_menu():
	game_panel.show()
	game_panel.set_position(Vector2(1016, 16))
	
	for key in WindowDict.keys():
		var window = WindowDict[key]
		window.hide()
		window.set_position(DEBUG_PANEL_COORD)
	print("Debug menu shown")

func close_debug_menu():
	for window in canvas_layer.get_children():
		window.hide()
