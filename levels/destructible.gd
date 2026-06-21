extends TileMapLayer

@onready var detector: Area2D = $Area2D
@export var full_charge_requirement: int

func _ready() -> void:
	detector.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player:
		Debug.log(str(player.velocity.length()))
		if player.velocity.length() >= 4000 and Game.full_charges >= full_charge_requirement:
			queue_free()
