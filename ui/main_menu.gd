extends Control

@onready var play_demo: Button = %Demo
@onready var start: Button = %Start
@onready var quit: Button = %Quit
@onready var credits: Button = %Credits
@onready var settings_btn: Button = %Settings

@onready var main_menu_panel: PanelContainer = %MainMenuPanel
@onready var settings_panel: PanelContainer = %SettingsPanel

@onready var volume_slider: HSlider = %VolumeSlider
@onready var settings_back_btn: Button = %SettingsBack

func _ready() -> void:
	play_demo.pressed.connect(_on_demo_pressed)
	start.pressed.connect(_on_start_pressed)
	quit.pressed.connect(_on_quit_pressed)
	credits.pressed.connect(_on_credits_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	
	settings_back_btn.pressed.connect(_on_settings_back_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)
	
	var bus_index = AudioServer.get_bus_index("Master")
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))


func _on_demo_pressed() -> void:
	LevelManager.playdemo()


func _on_start_pressed() -> void:
	LevelManager.start()


func _on_settings_pressed() -> void:
	main_menu_panel.visible = false
	settings_panel.visible = true


func _on_settings_back_pressed() -> void:
	settings_panel.visible = false
	main_menu_panel.visible = true


func _on_volume_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	LevelManager.credits()
