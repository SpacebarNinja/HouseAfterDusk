extends Control

@onready var settings_panel: Panel = $SettingsPanel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	settings_panel.hide()
	animation_player.play("initialize_menu")
	
func _on_play_button_pressed() -> void:
	Load.load_scene(self, "res://World/House/Scenes/game_scene.tscn")

func _on_settings_button_toggled(toggled_on: bool) -> void:
	settings_panel.visible = toggled_on

func _on_quit_button_pressed() -> void:
	get_tree().quit()
