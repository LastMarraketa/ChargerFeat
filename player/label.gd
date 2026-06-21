extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.full_charges_changed.connect(_on_full_charges_changed)
	text = str(Game.full_charges)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_full_charges_changed(new_value: int) -> void:
	text = str(new_value)
