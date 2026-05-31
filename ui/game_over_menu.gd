extends Control

@onready var retry_button: Button = %Retry
@onready var main_menu_button: Button = %MainMenu
@onready var quit_button: Button = %Quit

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    hide()
    retry_button.pressed.connect(_on_retry_pressed)
    main_menu_button.pressed.connect(_on_main_menu_pressed)
    quit_button.pressed.connect(_on_quit_pressed)
    Game.player_died.connect(_on_player_died)

func _on_player_died() -> void:
    get_tree().paused = true
    show()

func _on_retry_pressed() -> void:
    get_tree().paused = false
    get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
    get_tree().paused = false
    LevelManager.main_menu()

func _on_quit_pressed() -> void:
    get_tree().quit()
