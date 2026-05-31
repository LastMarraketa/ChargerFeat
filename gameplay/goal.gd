extends Area2D

@export var sfx: AudioStream

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	sprite.play("default")

func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player:
		Game.level_completed.emit()
		AudioManager.play_sfx(sfx)

		
