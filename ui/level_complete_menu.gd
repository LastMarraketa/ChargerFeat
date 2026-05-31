extends Control

@onready var next_button: Button = %NextButton
@onready var retry_button: Button = %Retry
@onready var main_menu_button: Button = %MainMenu
@onready var title_label: Label = %TitleLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	next_button.pressed.connect(_on_next_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	Game.level_completed.connect(_on_level_completed)

func _on_level_completed() -> void:
	get_tree().paused = true
	if LevelManager.has_next_level():
		title_label.text = "Level Complete"
		next_button.text = "Next Level"
	else:
		title_label.text = "Victory!"
		next_button.text = "Credits"
	show()

func _on_next_pressed() -> void:
	get_tree().paused = false
	if LevelManager.has_next_level():
		LevelManager.next_level()
	else:
		LevelManager.credits()

func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	LevelManager.main_menu()
