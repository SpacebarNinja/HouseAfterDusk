extends Panel

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var main_hud = get_tree().get_first_node_in_group("MainHud")
@onready var hud = get_tree().get_first_node_in_group("Hud")
@onready var camera = get_tree().get_first_node_in_group("MainCamera")

@onready var enemy_panel = $"../../EnemyWindow"
@onready var inventory_panel = $"../../InventoryWindow"

@onready var zoom_slider = $ZoomSlider
@onready var zoom_label = $ZoomSlider/Label
@onready var debug_mode_button = $EnableDebugMode

@onready var time_label = $TimeSlider/TimeLabel
@onready var time_slider = $TimeSlider

var zoom = 3.2

func _process(_delta):
	time_slider.value = WorldManager.WorldTime

# Others --------------------------------------------
func _on_zoom_slider_value_changed(value):
	zoom = zoom_slider.value/10
	zoom_label.text = str("Zoom: ", zoom)
	camera.target_zoom = Vector2(zoom,zoom)

func _on_enable_debug_mode_toggled(toggled_on: bool) -> void:
	if toggled_on:
		player.set_collision_mask_value(1, false)
		player.movement_speed = 400
		main_hud.debug_sprint = true
		debug_mode_button.self_modulate = Color(0,1,0, 1)
		print("Debug Mode enabled")
	else:
		player.set_collision_mask_value(1, true)
		player.movement_speed = 80
		main_hud.debug_sprint = false
		debug_mode_button.self_modulate = Color(1,1,1)
		debug_mode_button.release_focus()
		print("Debug Mode disabled")
		
func _on_kill_all_enemies_pressed():
	GameManager.kill_all_enemies()

func _on_time_slider_value_changed(value):
	time_label.text = "World Time: " + str(value)
	WorldManager.WorldTime = value
	
func _on_midnight_pressed():
	WorldManager.WorldTime = 0

func _on_noon_pressed():
	WorldManager.WorldTime = 1200

func _on_option_button_item_selected(index: int) -> void:
	var display = null
	
	match index:
		0:
			display = "Main"
		1:
			display = "Crafting"
		2:
			display = "Cooking"
		3:
			display = "Fishing"
	if display: hud.current_display(display)
	
func _on_player_stats_item_selected(index: int) -> void:
	match index:
		0:
			player.current_health = player.max_health
		1:
			player.current_hunger = player.max_hunger
		2:
			player.take_damage(20, Vector2.ZERO)
		3:
			player.current_hunger -= 10
			
#Debug_Panels -----------------------------------------
func _on_show_enemy_panel_pressed():
	enemy_panel.show()

func _on_show_inventory_panel_pressed():
	inventory_panel.show()
