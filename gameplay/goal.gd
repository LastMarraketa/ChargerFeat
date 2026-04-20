extends Area2D

@export var sfx: AudioStream


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player:
		LevelManager.next_level()
		AudioManager.play_sfx(sfx)
		
