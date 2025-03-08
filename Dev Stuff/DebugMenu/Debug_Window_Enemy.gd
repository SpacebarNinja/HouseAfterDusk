extends Panel

@onready var label1 = $WGButton/Label
@onready var label2 = $TvGButton/Label
@onready var label3 = $DollButton/Label
@onready var label4 = $DeerButton/Label

func update_labels():
	label1.text = str(GameManager.spawned_enemies["WindowGirlV2"]["amount"])
	label2.text = str(GameManager.spawned_enemies["ElectronicGuyV2"]["amount"])
	label3.text = str(GameManager.spawned_enemies["Doll"]["amount"])
	label4.text = str(GameManager.spawned_enemies["Deer"]["amount"])

func _on_wg_button_gui_input(_event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		GameManager.spawn_enemy(0)
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		GameManager.kill_enemy(0)
	update_labels()

func _on_tvg_button_gui_input(_event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		GameManager.spawn_enemy(1)
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		GameManager.kill_enemy(1)
	update_labels()

func _on_doll_button_gui_input(_event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		GameManager.spawn_enemy(2)
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		GameManager.kill_enemy(2)
	update_labels()

func _on_deer_button_gui_input(_event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		GameManager.spawn_enemy(3)
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		GameManager.kill_enemy(3)
	update_labels()
