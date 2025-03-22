extends CanvasLayer

const DEBUG_PANEL_COORD = Vector2(176, 16)
var WindowDict: Dictionary
var combo_state: int = 0

func _ready():
	WindowDict = {
		"game_panel": {"node": $GameWindow, "status": false},
		"enemy_panel": {"node": $EnemyWindow, "status": false},
		"inventory_panel": {"node": $InventoryWindow, "status": false}
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
	for window in get_children():
		if window is TextureRect:
			window.hide()

func handle_debug_tabs():
	var debug_tabs = {
		KEY_0: "game_panel",
		KEY_9: "enemy_panel",
		KEY_8: "inventory_panel"
	}
	
	for key in debug_tabs.keys():
		if Input.is_key_pressed(KEY_QUOTELEFT) and Input.is_key_pressed(key):
			if WindowDict[debug_tabs[key]]["status"] == false:
				open_debug_tab(debug_tabs[key])
			elif WindowDict[debug_tabs[key]]["status"] == true:
				close_debug_tab(debug_tabs[key])
			return
	
	if Input.is_key_pressed(KEY_QUOTELEFT) and Input.is_key_pressed(KEY_BACKSPACE):
		for key in debug_tabs.keys():
			close_debug_tab(debug_tabs[key])
