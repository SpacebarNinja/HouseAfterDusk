extends Control

@onready var canvas_layer = $CanvasLayer
@onready var trash_panel = $CanvasLayer/TrashPanel
@onready var trash_slot = $CanvasLayer/TrashPanel/Trash

const TRASH_SLOT_COORD = Vector2i(1080,40)
const DEBUG_PANEL_COORD = Vector2(176, 16)
var WindowDict: Dictionary
var combo_state: int = 0

func _ready():
	WindowDict = {
		"game_panel": {"node": $CanvasLayer/GameWindow, "status": false},
		"enemy_panel": {"node": $CanvasLayer/EnemyWindow, "status": false},
		"player_panel": {"node": $CanvasLayer/PlayerWindow, "status": false},
		"map_panel": {"node": $CanvasLayer/MapWindow, "status": false},
		"hud_panel": {"node": $CanvasLayer/HudWindow, "status": false},
		"inventory_panel": {"node": $CanvasLayer/InventoryWindow, "status": false}
	}
	
	for key in WindowDict.keys():
		WindowDict[key]["node"].hide()
	
func _process(_delta):
	handle_debug_tabs()
	
func open_debug_tab(tab: String):
	WindowDict[tab]["node"].show()
	WindowDict[tab]["status"] = true
	
func close_debug_tab(tab: String):
	WindowDict[tab]["node"].hide()
	WindowDict[tab]["status"] = false
	
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
			if WindowDict[debug_tabs[key]]["status"] == false:
				open_debug_tab(debug_tabs[key])
			elif WindowDict[debug_tabs[key]]["status"] == true:
				close_debug_tab(debug_tabs[key])
			trash_panel.show()
			return
	
	if Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_QUOTELEFT) and Input.is_key_pressed(KEY_BACKSPACE):
		for key in debug_tabs.keys():
			close_debug_tab(debug_tabs[key])
			trash_panel.hide()
	
func _on_trash_item_added(item):
	trash_slot.remove_item(item)
