extends Control

@onready var logoM: Sprite2D = $CenterContainer/SpriteM
@onready var logoS: Sprite2D = $CenterContainer/SpriteS
@onready var logoB: Sprite2D = $CenterContainer/SpriteB
@onready var logosoft: Sprite2D = $CenterContainer/Spritesoft
@onready var logo: Sprite2D = $CenterContainer/Spritelogo
@onready var logo_timer: Timer = $LogoTimer
@onready var end_timer: Timer = $EndTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Solo para que no haya audio en la grabación
	AudioManager.music_player.stop()
	logo_timer.timeout.connect(_on_logo_timeout)
	end_timer.timeout.connect(_on_end_timeout)
	var m_pos = Vector2(700,250)
	var s_pos = Vector2(650,540)
	var b_pos = Vector2(600,830)
	move_sprite(logoM, m_pos, 0.0, 0.5)
	move_sprite(logoS, s_pos, 0.3, 0.5)
	move_sprite(logoB, b_pos, 0.6, 0.5)

func _on_logo_timeout() -> void:
	show_logo(logo, 2.0)
	show_logo(logosoft, 2.0)
	end_timer.start()

func _on_end_timeout() -> void:
	#Debug.log("Se acaba el logo")
	pass

func move_sprite(spr: Sprite2D, new_pos: Vector2, start_time: float, duration: float) -> void:
	await get_tree().create_timer(start_time).timeout
	var tween = create_tween()
	tween.tween_property(spr, "global_position", new_pos, duration)

func show_logo(spr: Sprite2D, time: float) -> void:
	var tween = create_tween()
	tween.tween_property(spr, "self_modulate:a", 1.0, time)
