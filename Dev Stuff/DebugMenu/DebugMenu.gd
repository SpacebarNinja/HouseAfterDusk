extends Control

@onready var game_panel = $CanvasLayer/GameWindow
@onready var canvas_layer = $CanvasLayer

<<<<<<< Updated upstream
const DEBUG_PANEL_COORD = Vector2(176, 16)
=======
const TRASH_SLOT_COORD = Vector2i(1080,40)
const DEBUG_PANEL_COORD = Vector2(420, 16)
>>>>>>> Stashed changes
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
	
<<<<<<< Updated upstream
func open_debug_menu():
	game_panel.show()
	game_panel.set_position(Vector2(1016, 16))
	
	for key in WindowDict.keys():
		var window = WindowDict[key]
		window.hide()
		window.set_position(DEBUG_PANEL_COORD)
	print("Debug menu shown")
=======
func open_debug_tab(tab: String):
	WindowDict[tab].show()
	debugs_open = true
>>>>>>> Stashed changes

func close_debug_menu():
	for window in canvas_layer.get_children():
		window.hide()
<<<<<<< Updated upstream
=======
	for key in WindowDict.keys():
			WindowDict[key].set_position(DEBUG_PANEL_COORD)
	debugs_open = false
	
func handle_debug_tabs():
	var debug_tabs = {
		KEY_0: "game_panel",
		KEY_9: "enemy_panel",
		KEY_8: "player_panel",
		KEY_7: "map_panel",
		KEY_6: "hud_panel",
		KEY_5: "inventory_panel"
	}
	
	for key in debug_tabs.keys():
		if Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_QUOTELEFT) and Input.is_key_pressed(key):
			open_debug_tab(debug_tabs[key])
			return
	
	if Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_QUOTELEFT) and Input.is_key_pressed(KEY_BACKSPACE):
		close_debug_menu()

func _on_trash_item_added(item):
	trash_slot.remove_item(item)
>>>>>>> Stashed changes
