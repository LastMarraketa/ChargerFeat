## Gestiona la interfaz y comportamiento lógico del menú de fin de partida.
##
## Este menú se muestra cuando el jugador pierde toda su salud o vida.
## deteniendo la física y elementos del juego mediante pausa
## y permitiendo al usuario reiniciar, regresar al inicio o salir del juegazo.
extends Control

## Botón para reiniciar la escena activa del nivel.
@onready var retry_button: Button = %Retry
## Botón para redirigir al menú principal del juego.
@onready var main_menu_button: Button = %MainMenu
## Botón para cerrar la aplicación del juego.
@onready var quit_button: Button = %Quit

## Inicializa la interfaz configurando las señales de los botones y el evento de muerte.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	Game.player_died.connect(_on_player_died)

## Activa la visibilidad del menú de Game Over y pausa el árbol de escenas.
func _on_player_died() -> void:
	get_tree().paused = true
	show()

## Despausa el árbol de escenas y recarga el nivel actual desde el inicio.
func _on_retry_pressed() -> void:
	get_tree().paused = false
	Game.charge = 0.0
	Game.full_charges = 0
	Game.full_charge_limit = 1
	get_tree().reload_current_scene()

## Despausa el árbol de escenas y redirige al menú principal a través del gestor de niveles.
func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	LevelManager.main_menu()

## Finaliza la ejecución del proceso del juego de forma segura.
func _on_quit_pressed() -> void:
	get_tree().quit()
