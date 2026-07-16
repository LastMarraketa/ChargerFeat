extends Control

@onready var resume: Button = %Resume
@onready var retry: Button = %Retry
@onready var settings: Button = %Settings
@onready var main_menu: Button = %MainMenu

@onready var pause_menu_panel: PanelContainer = %PauseMenuPanel
@onready var settings_panel: PanelContainer = %SettingsPanel
@onready var volume_slider: HSlider = %VolumeSlider
@onready var settings_back_btn: Button = %SettingsBack

func _ready() -> void:
    hide()
    resume.pressed.connect(_on_resume_pressed)
    retry.pressed.connect(_on_retry_pressed)
    settings.pressed.connect(_on_settings_pressed)
    main_menu.pressed.connect(_on_main_menu_pressed)
    settings_back_btn.pressed.connect(_on_settings_back_pressed)
    volume_slider.value_changed.connect(_on_volume_changed)
    
    var bus_index = AudioServer.get_bus_index("Master")
    volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("menu"):
        get_tree().paused = not get_tree().paused
        visible = get_tree().paused
        if not visible:
            settings_panel.visible = false
            pause_menu_panel.visible = true


func _on_resume_pressed() -> void:
    get_tree().paused = false
    hide()
    settings_panel.visible = false
    pause_menu_panel.visible = true


func _on_retry_pressed() -> void:
    get_tree().paused = false
    Game._reset_charger_to_level()
    get_tree().reload_current_scene()


func _on_settings_pressed() -> void:
    pause_menu_panel.visible = false
    settings_panel.visible = true


func _on_settings_back_pressed() -> void:
    settings_panel.visible = false
    pause_menu_panel.visible = true


func _on_volume_changed(value: float) -> void:
    var bus_index = AudioServer.get_bus_index("Master")
    AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))


func _on_main_menu_pressed() -> void:
    get_tree().paused = false
    LevelManager.main_menu()
