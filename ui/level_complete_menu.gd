## Gestiona la interfaz y comportamiento lógico del menú de nivel superado.
##
## Este menú se muestra cuando el jugador alcanza la meta de un nivel (los que hay actualmente).
## Evalúa dinámicamente el progreso de la campaña y altera el flujo del botón
## de avance para cargar el siguiente nivel o pasar a la pantalla de créditos
## si se trata del escenario final del juego.
extends Control

## Botón dinámico para avanzar al siguiente nivel o mostrar los créditos finales.
@onready var next_button: Button = %NextButton
## Botón para reiniciar el nivel actual desde el inicio.
@onready var retry_button: Button = %Retry
## Botón para regresar al menú principal del juego.
@onready var main_menu_button: Button = %MainMenu
## Etiqueta de texto utilizada para mostrar el título de forma dinámica.
@onready var title_label: Label = %TitleLabel

## Inicializa la interfaz configurando las señales de los botones y el evento de victoria.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	next_button.pressed.connect(_on_next_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	Game.level_completed.connect(_on_level_completed)

## Activa la visibilidad del menú de nivel superado, pausa el árbol de escenas y configura dinámicamente los textos.
func _on_level_completed() -> void:
	get_tree().paused = true
	if LevelManager.has_next_level():
		title_label.text = "Level Complete"
		next_button.text = "Next Level"
	else:
		title_label.text = "Victory!"
		next_button.text = "Credits"
	show()

## Despausa el árbol de escenas y avanza de nivel o carga los créditos según la disponibilidad de escenarios.
func _on_next_pressed() -> void:
	get_tree().paused = false
	if LevelManager.has_next_level():
		Game.level_start_full_charge_limit = Game.full_charge_limit
		LevelManager.next_level()
	else:
		Game._reset_charger_to_start()
		LevelManager.credits()

## Despausa el árbol de escenas y recarga el nivel actual desde el inicio.
func _on_retry_pressed() -> void:
	get_tree().paused = false
	Game._reset_charger_to_level()
	get_tree().reload_current_scene()

## Despausa el árbol de escenas y redirige al menú principal a través del gestor de niveles.
func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	Game._reset_charger_to_start()
	LevelManager.main_menu()
