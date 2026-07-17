extends TileMapLayer

@onready var detector: Area2D = $Area2D
@export var full_charge_requirement: int

func _ready() -> void:
	Game.update_destructible_terrain.connect(_on_terrain_update)
	detector.body_entered.connect(_on_body_entered)
	_on_terrain_update()

func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player:
		if  player.just_full_dashed and Game.full_charges >= full_charge_requirement:
			queue_free()

func _on_terrain_update() -> void:
	if Game.full_charge_limit >= full_charge_requirement:
		modulate = Color("c8ffdcf0")
	else:
		modulate = Color("ffc7c7f0")
