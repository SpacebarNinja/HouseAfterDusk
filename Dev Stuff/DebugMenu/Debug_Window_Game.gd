extends Panel

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var main_hud = get_tree().get_first_node_in_group("MainHud")
@onready var hud = get_tree().get_first_node_in_group("Hud")
@onready var map = get_tree().get_first_node_in_group("Map")
@onready var camera = get_tree().get_first_node_in_group("MainCamera")

@onready var enemy_panel = $"../../EnemyWindow"
@onready var player_panel = $"../../PlayerWindow"
@onready var map_panel = $"../../MapWindow"
@onready var hud_panel = $"../../HudWindow"
@onready var inventory_panel = $"../../InventoryWindow"

@onready var zoom_slider = $ZoomSlider
@onready var zoom_label = $ZoomSlider/Label
@onready var noclip_button = $EnableNoclip
@onready var time_label = $TimeSlider/TimeLabel
@onready var time_slider = $TimeSlider
@onready var infinite_sprint_button = $InfiniteSprint

var no_clip_enabled: bool = false

var zoom = 3.2

func _process(_delta):
	time_slider.value = WorldManager.WorldTime

# Others --------------------------------------------
func _on_zoom_slider_value_changed(value):
	zoom = zoom_slider.value/10
	zoom_label.text = str("Zoom: ", zoom)
	camera.zoom = Vector2(zoom,zoom)
		
func _on_enable_noclip_pressed():
	if not no_clip_enabled:
		player.set_collision_mask_value(1, false)
		no_clip_enabled = true
		noclip_button.self_modulate = Color(0,1,0, 1)
		print("No-clip enabled")
	else:
		player.set_collision_mask_value(1, true)
		no_clip_enabled = false
		noclip_button.self_modulate = Color(1,1,1)
		noclip_button.release_focus()
		print("No-clip disabled")
		
func _on_kill_all_enemies_pressed():
	GameManager.kill_all_enemies()

func _on_time_slider_value_changed(value):
	time_label.text = "World Time: " + str(value)
	WorldManager.WorldTime = value
	
func _on_midnight_pressed():
	WorldManager.WorldTime = 0

func _on_noon_pressed():
	WorldManager.WorldTime = 1200

func _on_infinite_sprint_toggled(toggled_on):
	if toggled_on:
		player.set_walk_speed(400)
		main_hud.debug_sprint = true
		infinite_sprint_button.self_modulate = Color(0,1,0, 1)
	else:
		player.set_walk_speed(80)
		main_hud.debug_sprint = false
		infinite_sprint_button.self_modulate = Color(1,1,1)

#Debug_Panels -----------------------------------------
func _on_show_player_panel_pressed():
	player_panel.show()

func _on_show_map_panel_pressed():
	map_panel.show()

func _on_show_enemy_panel_pressed():
	enemy_panel.show()

func _on_show_inventory_panel_pressed():
	inventory_panel.show()

func _on_show_hud_panel_pressed():
	hud_panel.show()
