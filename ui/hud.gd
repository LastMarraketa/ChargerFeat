extends CanvasLayer

@onready var coins_label: Label = %CoinsLabel

func _ready() -> void:
	_on_coins_changed(Game.coins)
	Game.coins_changed.connect(_on_coins_changed)

func _on_coins_changed(value: int) -> void:
	coins_label.text = str(value)
