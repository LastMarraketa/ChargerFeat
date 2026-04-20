class_name Tile
extends Button

signal tile_pressed

enum Type {
	BLUE,
	RED
}

var type = Type.BLUE

func _ready() -> void:
	pressed.connect(_on_tile_pressed)
	_update()

func _on_tile_pressed() -> void:
	if type == Type.BLUE:
		type = Type.RED
	else:
		type = Type.BLUE
	_update()
	tile_pressed.emit()

func _update() -> void:
	theme_type_variation = "BlueButton" if type == Type.BLUE else "RedButton"

func pick_random() -> void:
	type = Type.BLUE if randi() % 2 else Type.RED
	_update()

func toggle() -> void:
	if type == Type.BLUE:
		type = Type.RED
	else:
		type = Type.BLUE
	_update()

func simulate_press() -> void:
	_on_tile_pressed()
