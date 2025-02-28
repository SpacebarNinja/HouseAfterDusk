extends Control

@onready var canvas_layer = $CanvasLayer
@onready var trash_panel = $CanvasLayer/TrashPanel
@onready var trash_slot = $CanvasLayer/TrashPanel/Trash

const TRASH_SLOT_COORD = Vector2i(1080,40)
const DEBUG_PANEL_COORD = Vector2(176, 16)
var WindowDict: Dictionary
var debugs_open: bool
var combo_state: int = 0

func _ready():
	WindowDict = {
		"game_panel": $CanvasLayer/GameWindow,
		"enemy_panel":$CanvasLayer/EnemyWindow,
		"player_panel": $CanvasLayer/PlayerWindow,
		"map_panel": $CanvasLayer/MapWindow,
		"hud_panel": $CanvasLayer/HudWindow,
		"inventory_panel": $CanvasLayer/InventoryWindow
	}
	
	for key in WindowDict.keys():
		WindowDict[key].hide()
	
func _process(_delta):
	trash_panel.visible = debugs_open
	handle_debug_tabs()
	
func open_debug_tab(tab: String):
	WindowDict[tab].show()

func close_debug_menu():
	for window in canvas_layer.get_children():
		window.hide()

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
			debugs_open = true
			return
	
	if Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_QUOTELEFT) and Input.is_key_pressed(KEY_BACKSPACE):
		close_debug_menu()
		debugs_open = false
	
func _on_trash_item_added(item):
	trash_slot.remove_item(item)
