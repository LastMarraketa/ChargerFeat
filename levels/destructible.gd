extends TileMapLayer

@onready var detector: Area2D = $Area2D

func _ready() -> void:
	detector.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player:
		Debug.log(str(player.velocity.length()))
		if player.velocity.length() >= 4000:
			queue_free()
